#!/usr/bin/env bash
# Tear down a local HTTPS dev domain set up by setup.sh.
# Usage: teardown.sh <domain>
#
# Removes the domain's nginx config and dnsmasq override, then regenerates the
# shared `local-dev.pem` cert with the remaining domains so it stays minimal.
# If invoked from inside a Next.js project, also strips the domain from the
# next.config's `allowedDevOrigins`.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <domain>" >&2
  exit 2
fi

DOMAIN="$1"
NGINX_DIR="/opt/homebrew/etc/nginx"
CERTS_DIR="$NGINX_DIR/certs"
SERVERS_DIR="$NGINX_DIR/servers"
DNSMASQ_CONF="/opt/homebrew/etc/dnsmasq.conf"

CONF="$SERVERS_DIR/$DOMAIN.conf"
[[ -f "$CONF" ]] && { rm -v "$CONF"; } || echo "[skip] no nginx config for $DOMAIN"

# Remove any per-domain dnsmasq override (private 127.0.0.1 or shared LAN IP).
# BSD sed needs the empty backup suffix. The shared interface= line is left
# alone — it's harmless and may still serve other shared domains.
if grep -qE "^address=/$DOMAIN/" "$DNSMASQ_CONF"; then
  sed -i '' "\|^address=/$DOMAIN/|d" "$DNSMASQ_CONF"
  echo "[dnsmasq] removed override for $DOMAIN"
else
  echo "[skip] $DOMAIN not overridden in dnsmasq.conf (covered by the .test wildcard)"
fi

# Regenerate shared cert with whatever domains remain.
# zsh doesn't word-split unquoted vars, so feed names to mkcert via xargs.
remaining=$(
  grep -hE '^[[:space:]]*server_name[[:space:]]' "$SERVERS_DIR"/*.conf 2>/dev/null \
    | sed -E 's/^[[:space:]]*server_name[[:space:]]+//; s/;.*$//' \
    | tr ' ' '\n' \
    | grep -E '^(\*\.)?[a-z0-9][a-z0-9.-]+$' \
    | sort -u \
    || true
)
if [[ -n "$remaining" ]]; then
  echo "[mkcert] regenerating local-dev.pem ($(printf '%s\n' "$remaining" | wc -l | tr -d ' ') names)"
  ( cd "$CERTS_DIR" && printf '%s\n' "$remaining" | xargs mkcert -cert-file=local-dev.pem -key-file=local-dev-key.pem >/dev/null )
else
  echo "[mkcert] no domains left — removing local-dev cert"
  rm -f "$CERTS_DIR/local-dev.pem" "$CERTS_DIR/local-dev-key.pem"
fi

# --- Next.js: strip from allowedDevOrigins ---------------------------------
find_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/package.json" ]] && { echo "$dir"; return 0; }
    dir=$(dirname "$dir")
  done
  return 1
}

strip_next_config() {
  local proj_dir
  proj_dir=$(find_project_root) || return 0
  [[ -f "$proj_dir/package.json" ]] || return 0
  grep -q '"next"' "$proj_dir/package.json" || return 0

  local config=""
  for f in next.config.mjs next.config.js next.config.ts next.config.cjs; do
    [[ -f "$proj_dir/$f" ]] && { config="$proj_dir/$f"; break; }
  done
  [[ -n "$config" ]] || return 0

  grep -q "['\"]${DOMAIN}['\"]" "$config" || return 0

  # Strip "$DOMAIN", and , "$DOMAIN" — covers both single and double quotes,
  # and either order in the array.
  sed -i.bak -E \
    -e "s/[[:space:]]*['\"]${DOMAIN}['\"][[:space:]]*,//g" \
    -e "s/,[[:space:]]*['\"]${DOMAIN}['\"][[:space:]]*//g" \
    -e "s/['\"]${DOMAIN}['\"]//g" \
    "$config"
  rm -f "${config}.bak"
  echo "[next.js] removed '$DOMAIN' from $(basename "$config")"
}
strip_next_config

cat <<EOF

==============================================================================
Removed. Apply changes with:

  sudo brew services restart nginx
  sudo brew services restart dnsmasq
  sudo dscacheutil -flushcache
==============================================================================
EOF
