#!/usr/bin/env bash
# Set up a local HTTPS dev domain on macOS.
# Usage: setup.sh [--shared] <domain> <upstream-port>
#   e.g.: setup.sh myapp.test 3001          # PRIVATE: only this Mac
#         setup.sh --shared esora.test 5173     # SHARED: reachable from the LAN
#
# Two tiers (private by default, shared by exception):
#
#   PRIVATE (default) — resolves to 127.0.0.1 via the dnsmasq `.test` wildcard,
#     and the nginx server block rejects any source IP except loopback
#     (allow 127.0.0.1/::1; deny all). Only this Mac can reach it; a LAN device
#     that guesses the Mac's IP and spoofs the Host header is still denied.
#
#   SHARED (--shared) — resolves to this Mac's CURRENT LAN IP (auto-detected),
#     dnsmasq is told to answer on that interface, and the nginx block serves
#     without an allow/deny rule, so other devices on the network can reach it.
#     For a LAN device to actually use it, that device must (a) use this Mac as
#     its DNS resolver, or add a `<LAN_IP> <domain>` hosts entry, and (b) trust
#     the mkcert root CA (~/Library/Application Support/mkcert/rootCA.pem).
#     The LAN IP is pinned at setup time — re-run --shared if your IP changes.
#
# Single shared SAN cert (`local-dev.pem`) covers every dev domain. On each run
# we re-discover the hostnames already configured in
# /opt/homebrew/etc/nginx/servers/, add the new one, and regenerate the cert
# with all names listed as SANs.
#
# Next.js integration: if invoked from inside a Next.js project (package.json
# lists `next` and a next.config.{js,mjs,ts} exists), the domain is added to
# `allowedDevOrigins` so Next stops blocking dev requests from the new host.
#
# Control-panel services: if the domain is registered in
# ~/localhost/control-panel/services.json, the block omits dev-no-cache.conf —
# those hosts serve production builds whose hashed assets should be cached.

set -euo pipefail

SHARED=0
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --shared|--public) SHARED=1 ;;   # --public kept as a legacy alias
    -h|--help)
      grep -E '^# ' "$0" | sed 's/^# //'
      exit 0
      ;;
    *) ARGS+=("$arg") ;;
  esac
done
set -- "${ARGS[@]}"

if [[ $# -ne 2 ]]; then
  echo "usage: $0 [--shared] <domain> <upstream-port>" >&2
  exit 2
fi

DOMAIN="$1"
PORT="$2"
NGINX_DIR="/opt/homebrew/etc/nginx"
CERTS_DIR="$NGINX_DIR/certs"
SERVERS_DIR="$NGINX_DIR/servers"
DNSMASQ_CONF="/opt/homebrew/etc/dnsmasq.conf"
NGINX_BIN="/opt/homebrew/bin/nginx"
CERT="$CERTS_DIR/local-dev.pem"
KEY="$CERTS_DIR/local-dev-key.pem"
WILDCARD="address=/test/127.0.0.1"
INVOKER_PWD="${INVOKER_PWD:-$PWD}"

[[ "$DOMAIN" =~ ^[a-z0-9.-]+\.[a-z]+$ ]] || {
  echo "error: '$DOMAIN' doesn't look like a hostname" >&2
  exit 1
}
[[ "$PORT" =~ ^[0-9]+$ ]] || {
  echo "error: port '$PORT' must be numeric" >&2
  exit 1
}
command -v mkcert >/dev/null || { echo "error: mkcert not installed (brew install mkcert)" >&2; exit 1; }
[[ -d "$NGINX_DIR" ]] || { echo "error: $NGINX_DIR not found (brew install nginx)" >&2; exit 1; }
[[ -f "$DNSMASQ_CONF" ]] || { echo "error: $DNSMASQ_CONF not found (brew install dnsmasq)" >&2; exit 1; }

mkdir -p "$CERTS_DIR" "$SERVERS_DIR"

# --- 0. detect LAN IP (only needed when sharing) ---------------------------
# Use the interface backing the default route, falling back to en0.
detect_lan_interface() {
  local iface
  iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')
  printf '%s' "${iface:-en0}"
}

detect_lan_ip() {
  local ip
  ip=$(ipconfig getifaddr "$(detect_lan_interface)" 2>/dev/null || true)
  [[ -z "${ip:-}" ]] && ip=$(ipconfig getifaddr en0 2>/dev/null || true)
  printf '%s' "${ip:-}"
}

LAN_IP=""
if [[ $SHARED -eq 1 ]]; then
  LAN_IP=$(detect_lan_ip)
  [[ -n "$LAN_IP" ]] || {
    echo "error: couldn't detect this Mac's LAN IP — are you on a network?" >&2
    exit 1
  }
fi

# --- 1. shared SAN cert ----------------------------------------------------
# zsh doesn't word-split unquoted vars, so feed names to mkcert via xargs.
existing=$(
  grep -hE '^[[:space:]]*server_name[[:space:]]' "$SERVERS_DIR"/*.conf 2>/dev/null \
    | sed -E 's/^[[:space:]]*server_name[[:space:]]+//; s/;.*$//' \
    | tr ' ' '\n' \
    | grep -E '^(\*\.)?[a-z0-9][a-z0-9.-]+$' \
    || true
)
all_names=$(printf '%s\n%s\n' "$existing" "$DOMAIN" | sort -u | grep -v '^$')
echo "[mkcert] regenerating $CERT ($(printf '%s\n' "$all_names" | wc -l | tr -d ' ') names)"
( cd "$CERTS_DIR" && printf '%s\n' "$all_names" | xargs mkcert -cert-file=local-dev.pem -key-file=local-dev-key.pem >/dev/null )

# --- 2. dnsmasq entry ------------------------------------------------------
# Strip any existing override for this domain so re-runs and tier-flips start
# clean. BSD sed needs the empty backup suffix.
DNS_CHANGED=0
if grep -qE "^address=/$DOMAIN/" "$DNSMASQ_CONF"; then
  sed -i '' "\|^address=/$DOMAIN/|d" "$DNSMASQ_CONF"
  DNS_CHANGED=1
fi

if [[ $SHARED -eq 1 ]]; then
  echo "[dnsmasq] $DOMAIN -> $LAN_IP (shared)"
  printf '%s\n' "address=/$DOMAIN/$LAN_IP" >> "$DNSMASQ_CONF"
  # Listen on the LAN *interface*, never a pinned LAN IP: bind-dynamic does not
  # skip a listen-address that no longer exists — dnsmasq exits 2 at every start
  # (including boot) and all .test resolution dies. interface= + bind-dynamic
  # follows the interface's address and tolerates it having none yet at boot.
  LAN_IF=$(detect_lan_interface)
  grep -qFx "bind-dynamic" "$DNSMASQ_CONF" || printf '%s\n' "bind-dynamic" >> "$DNSMASQ_CONF"
  if grep -E '^listen-address=' "$DNSMASQ_CONF" | grep -qv '^listen-address=127\.0\.0\.1$'; then
    echo "[dnsmasq] removing legacy pinned listen-address line(s)"
    sed -i '' '/^listen-address=/{/^listen-address=127\.0\.0\.1$/!d;}' "$DNSMASQ_CONF"
  fi
  if ! grep -qFx "interface=$LAN_IF" "$DNSMASQ_CONF"; then
    echo "[dnsmasq] answering on LAN interface ($LAN_IF)"
    printf '%s\n' "interface=$LAN_IF" >> "$DNSMASQ_CONF"
  fi
  DNS_CHANGED=1
elif grep -qFx "$WILDCARD" "$DNSMASQ_CONF"; then
  echo "[dnsmasq] $DOMAIN covered by wildcard ($WILDCARD)"
else
  echo "[dnsmasq] $DOMAIN -> 127.0.0.1 (private)"
  printf '%s\n' "address=/$DOMAIN/127.0.0.1" >> "$DNSMASQ_CONF"
  DNS_CHANGED=1
fi

# --- 3. shared snippets ----------------------------------------------------
SNIPPETS_DIR="$NGINX_DIR/snippets"
mkdir -p "$SNIPPETS_DIR"

PROXY_SNIPPET="$SNIPPETS_DIR/proxy-common.conf"
if [[ ! -f "$PROXY_SNIPPET" ]]; then
  echo "[snippet] creating $PROXY_SNIPPET"
  cat > "$PROXY_SNIPPET" <<'SNIPPET'
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection 'upgrade';
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_cache_bypass $http_upgrade;
proxy_read_timeout 300s;
proxy_connect_timeout 75s;
SNIPPET
fi

NOCACHE_SNIPPET="$SNIPPETS_DIR/dev-no-cache.conf"
if [[ ! -f "$NOCACHE_SNIPPET" ]]; then
  echo "[snippet] creating $NOCACHE_SNIPPET"
  cat > "$NOCACHE_SNIPPET" <<'SNIPPET'
proxy_hide_header ETag;
proxy_hide_header Last-Modified;
add_header Cache-Control "no-store, no-cache, must-revalidate" always;
add_header Pragma "no-cache" always;
add_header Expires "0" always;
SNIPPET
fi

# --- 4. nginx server block -------------------------------------------------
CONF="$SERVERS_DIR/$DOMAIN.conf"

if [[ $SHARED -eq 1 ]]; then
  ACCESS_BLOCK=""
  ACCESS_NOTE="# SHARED with the LAN: resolves to this Mac's LAN IP ($LAN_IP) and serves
# without an allow/deny block, so other devices on the network can reach it."
  MODE="shared (LAN-reachable via $LAN_IP)"
else
  ACCESS_BLOCK=$'\n    # Private to this Mac. Re-run setup.sh with --shared to expose to the LAN.\n    allow 127.0.0.1;\n    allow ::1;\n    deny all;\n'
  ACCESS_NOTE="# Private to this Mac. Pass --shared to setup.sh to expose to the LAN."
  MODE="private (loopback-only)"
fi

# Only a pure dev server wants no-store. A control-panel service serves a
# production build when idle, and no-store would keep its hashed assets from
# ever being cached.
NOCACHE_INCLUDE=$'        include snippets/dev-no-cache.conf;\n'
SERVICES_JSON="$HOME/localhost/control-panel/services.json"
if [[ -f "$SERVICES_JSON" ]] && grep -qF "\"https://$DOMAIN\"" "$SERVICES_JSON"; then
  NOCACHE_INCLUDE=""
  echo "[nginx] $DOMAIN is a control-panel service — omitting dev-no-cache.conf"
fi

echo "[nginx] writing $CONF (proxy → http://localhost:$PORT, $MODE)"
{
  echo "# Generated by ~/.claude/skills/local-https-domain"
  echo "$ACCESS_NOTE"
  echo "server {"
  echo "    listen 80;"
  echo "    server_name $DOMAIN;"
  printf '%s' "$ACCESS_BLOCK"
  echo "    return 301 https://$DOMAIN\$request_uri;"
  echo "}"
  echo
  echo "server {"
  echo "    listen 443 ssl;"
  echo "    server_name $DOMAIN;"
  printf '%s' "$ACCESS_BLOCK"
  echo "    ssl_certificate     $CERT;"
  echo "    ssl_certificate_key $KEY;"
  echo
  echo "    location / {"
  echo "        proxy_pass http://localhost:$PORT;"
  echo "        include snippets/proxy-common.conf;"
  printf '%s' "$NOCACHE_INCLUDE"
  echo "    }"
  echo "}"
} > "$CONF"

# --- 5. validate -----------------------------------------------------------
echo "[nginx -t] validating config (best-effort — a real check needs sudo nginx -t)"
"$NGINX_BIN" -t 2>&1 | grep -vE 'open\(\) "/.*\.pid" failed|test failed$' || true

# --- 6. Next.js: append to allowedDevOrigins ------------------------------
find_project_root() {
  local dir="$INVOKER_PWD"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/package.json" ]] && { echo "$dir"; return 0; }
    dir=$(dirname "$dir")
  done
  return 1
}

update_next_config() {
  local proj_dir
  proj_dir=$(find_project_root) || { return 0; }
  [[ -f "$proj_dir/package.json" ]] || return 0
  grep -q '"next"' "$proj_dir/package.json" || return 0

  local config=""
  for f in next.config.mjs next.config.js next.config.ts next.config.cjs; do
    [[ -f "$proj_dir/$f" ]] && { config="$proj_dir/$f"; break; }
  done
  [[ -n "$config" ]] || {
    echo "[next.js] detected (in $proj_dir) but no next.config.* found — skipping"
    return 0
  }

  if grep -q "['\"]${DOMAIN}['\"]" "$config"; then
    echo "[next.js] $DOMAIN already in $(basename "$config")"
    return 0
  fi

  if grep -qE 'allowedDevOrigins[[:space:]]*:[[:space:]]*\[' "$config"; then
    sed -i.bak -E "s/(allowedDevOrigins[[:space:]]*:[[:space:]]*\[)/\1'${DOMAIN}', /" "$config"
    rm -f "${config}.bak"
    echo "[next.js] added '$DOMAIN' to existing allowedDevOrigins in $(basename "$config")"
    return 0
  fi

  if grep -qE 'const[[:space:]]+nextConfig[[:space:]]*=[[:space:]]*\{' "$config"; then
    awk -v line="  allowedDevOrigins: ['${DOMAIN}']," '
      !inserted && /const[[:space:]]+nextConfig[[:space:]]*=[[:space:]]*\{[[:space:]]*$/ {
        print
        print line
        inserted = 1
        next
      }
      { print }
    ' "$config" > "${config}.tmp" && mv "${config}.tmp" "$config"
    echo "[next.js] added allowedDevOrigins: ['${DOMAIN}'] to $(basename "$config")"
    return 0
  fi

  echo "[next.js] couldn't auto-edit $(basename "$config") — add manually:"
  echo "          allowedDevOrigins: ['${DOMAIN}']"
}
update_next_config

# --- 7. instructions -------------------------------------------------------
cat <<EOF

==============================================================================
DONE (no-sudo phase). To activate, run:

  sudo brew services restart nginx           # cert regen + new server block
EOF
if [[ $DNS_CHANGED -eq 1 ]]; then
  cat <<EOF
  sudo brew services restart dnsmasq         # picks up the $DOMAIN DNS change
  sudo dscacheutil -flushcache
EOF
fi
cat <<EOF

Then your dev server on localhost:$PORT is reachable at:
  https://$DOMAIN
  ($MODE)
EOF
if [[ $SHARED -eq 1 ]]; then
  cat <<EOF

To reach https://$DOMAIN from ANOTHER device on the LAN, that device must:
  1. Use this Mac ($LAN_IP) as its DNS resolver, OR add a hosts entry:
        $LAN_IP $DOMAIN
  2. Trust the mkcert root CA, or it'll warn on the cert. Copy
        ~/Library/Application Support/mkcert/rootCA.pem
     to the device and install it (System trust on iOS/macOS, etc).
NOTE: $LAN_IP is pinned. If this Mac's LAN IP changes, re-run --shared.
EOF
fi
echo "=============================================================================="
