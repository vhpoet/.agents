---
name: local-https-domain
description: Set up a local HTTPS dev domain on macOS with mkcert, dnsmasq, and nginx. Use when local dev needs a real https:// URL — an OAuth redirect_uri rejecting localhost, service workers, Secure cookies.
---

# Local HTTPS Dev Domain (macOS)

Turns `https://<domain>.test` into a TLS-terminating reverse proxy in front of a dev server on `http://localhost:<port>`. macOS-only, assumes Homebrew-installed `mkcert`, `nginx`, `dnsmasq`.

## Triggers

Requests like "I need an https domain for local dev", "set up myapp.test with https", "make this work over https locally", "Plaid rejected my localhost redirect", or any prompt about local TLS / self-signed certs paired with nginx or dnsmasq. Typically an OAuth provider (Plaid, Google, GitHub, Stripe…) refuses `http://localhost` as a `redirect_uri`, or you are testing service workers, Secure cookies, or HTTPS-only browser features. One cert (`local-dev.pem`) covers every dev domain — regenerated each run so SANs stay current.

## Two tiers: private by default, shared by exception

A domain's tier is set by **both** DNS (what it resolves to) and nginx (which source IPs the block accepts). The two must agree or the domain breaks.

| | resolves to | nginx block | reachable from |
|---|---|---|---|
| **PRIVATE** (default) | `127.0.0.1` (via `.test` wildcard) | `allow 127.0.0.1; allow ::1; deny all;` | this Mac only |
| **SHARED** (`--shared`) | this Mac's current LAN IP | no allow/deny | this Mac + the LAN |

> **The trap:** if a domain resolves to the LAN IP but nginx still says `deny all`, even *this Mac* gets a 403 — connecting to your own LAN IP makes nginx see the client as the LAN IP, not `127.0.0.1`. So the wildcard must stay `127.0.0.1` and only `--shared` domains get a LAN-IP override. **Never point the `.test` wildcard at the LAN IP.**

A LAN device using a shared domain must (a) use this Mac as its DNS resolver (or add a `<LAN_IP> <domain>` hosts entry) and (b) trust the mkcert root CA. The LAN IP is **pinned** at setup — re-run `--shared` if it changes.

## Cert model: one shared SAN cert

A single `local-dev.pem` (+ key) covers every domain. Each run scans `servers/*.conf` for every `server_name`, adds the new domain, and regenerates the cert with all names as SANs — **no per-domain cert files**. This avoids cert sprawl, and explicit SAN names sidestep the fact that `*.test` wildcard certs are rejected by Chrome/Safari (mkcert warns about this too).

## Shared nginx snippets

Boilerplate lives in `/opt/homebrew/etc/nginx/snippets/`, so per-project blocks shrink to ~10 lines and central tweaks propagate on `sudo nginx -s reload`:

- `proxy-common.conf` — `proxy_http_version`, websocket upgrade, forwarded headers, timeouts.
- `dev-no-cache.conf` — strips `ETag`/`Last-Modified`, forces `Cache-Control: no-store` so edits aren't cached.
- `runtime-dns.conf` — a `resolver` directive; include it in any location whose `proxy_pass` targets a public host, together with a `set $upstream …` variable, so nginx resolves the name per request instead of at startup (see pitfalls).

```nginx
location / {
    proxy_pass http://localhost:$PORT;
    include snippets/proxy-common.conf;
    include snippets/dev-no-cache.conf;
}
```

Bind the app to `localhost` (both `127.0.0.1` and `::1`), not `127.0.0.1` alone — nginx's `proxy_pass http://localhost:PORT` tries `::1` first and returns 502 otherwise.

Include `snippets/dev-no-cache.conf` **only for hosts backed by a pure dev server**. Hosts that are control-panel services (`~/localhost/control-panel/services.json`) serve production builds — omit it, or the build's hashed assets are never cached. `setup.sh` decides this itself by matching the domain against the services' `url` fields.

## Prerequisites (one-time)

Verify with `brew list | grep -E '^(mkcert|nginx|dnsmasq)$'`, then:

```bash
brew install mkcert nginx dnsmasq
mkcert -install                                  # local CA into system trust
sudo brew services start dnsmasq
sudo brew services start nginx

sudo mkdir -p /etc/resolver                       # route *.test → local dnsmasq
echo 'nameserver 127.0.0.1' | sudo tee /etc/resolver/test
```

In `/opt/homebrew/etc/dnsmasq.conf`, ensure these lines exist:

```
address=/test/127.0.0.1     # wildcard: every *.test is PRIVATE (loopback) by default
listen-address=127.0.0.1
interface=en0               # LAN side: bind the interface, never a pinned LAN IP
bind-dynamic                # follow the interface's address; tolerate it having
                            # no address yet at boot
```

Never write `listen-address=<LAN IP>`: bind-dynamic does NOT skip a missing address. A pinned LAN IP that no longer exists (after a network change) makes dnsmasq exit with code 2 at every start, including at boot, and all `.test` resolution dies.

With the wildcard present, `setup.sh` never touches DNS for private domains; only `--shared` domains add an `address=/<domain>/<LAN_IP>` override (most-specific match wins).

## Per-domain setup

Run from inside the project directory with the domain (`name.tld`) and upstream port. No root required.

```bash
~/.claude/skills/local-https-domain/scripts/setup.sh myapp.test 3001        # private
~/.claude/skills/local-https-domain/scripts/setup.sh --shared esora.test 5173   # LAN
```

What it does:

1. **Cert** — regenerates the shared SAN cert from every `server_name` plus the new domain (fed to mkcert via `xargs`, since zsh doesn't word-split unquoted vars).
2. **dnsmasq** — strips any stale override for the domain; private relies on the wildcard (adds a per-domain `127.0.0.1` line only if the wildcard is missing); `--shared` adds the `<LAN_IP>` override + ensures `listen-address=<LAN_IP>` and `bind-dynamic`.
3. **nginx** — writes `servers/<domain>.conf` (80→443 redirect + TLS proxy). Private blocks include `allow 127.0.0.1; allow ::1; deny all;`; `--shared` omits it. `dev-no-cache.conf` is included only for pure dev servers, not for control-panel services (see *Shared nginx snippets*).
4. **Next.js** — if a parent `package.json` lists `next`, adds the domain to `allowedDevOrigins` in `next.config.*` (avoids Next 15+ cross-origin/HMR breakage). Skipped otherwise.
5. **Validates** the nginx config and **prints** the sudo activation commands.

Idempotent — re-running flips a domain between private and `--shared` by rewriting both the dnsmasq override and the nginx block.

**Activate (sudo — the script prints exactly which apply):**

```bash
sudo brew services restart nginx                 # always: new cert + server block
sudo brew services restart dnsmasq               # only if DNS changed (--shared, or
sudo dscacheutil -flushcache                      #   a private domain with no wildcard)
```

Homebrew nginx runs its master as root, so **every** `nginx -t` / `nginx -s reload` needs `sudo` — and agents can't run sudo. Hand this step to the founder; for a config-only change (new/edited server block or snippet, no new cert) the one-liner to type at the prompt, with `!` as the very first character, is:

```
!sudo nginx -t && sudo nginx -s reload
```

## Verifying

```bash
curl -I https://<domain>     # hits the dev server, no cert warning (502 = dev server down, nginx is fine)
```

Chrome caches cert errors aggressively — hard-reload (`cmd+shift+R`).

## Common pitfalls

- **Never run `brew services start nginx` / `dnsmasq` without `sudo`**: it creates a second, user-level launchd registration next to the root daemon. The user-level dnsmasq cannot bind port 53 and crash-loops; the user-level nginx shadows the root one. If `brew services list` shows a `~/Library/LaunchAgents` path for either, run `brew services stop <name>` (as the user) to remove it, then `sudo brew services restart <name>`.
- **nginx dies at boot with `host not found in upstream "<public host>"`**: a literal `proxy_pass https://<public host>` is resolved while parsing the config, before the network is up, and nginx has no KeepAlive. Resolve at request time instead: `include snippets/runtime-dns.conf;` then `set $upstream https://<public host>;` and `proxy_pass $upstream;` (or `$upstream/path` — with a variable the given URI is sent as-is).
- **Domain must be `.test`** (or another suffix with its own `/etc/resolver/<suffix>`). Real TLDs route to public DNS and skip dnsmasq.
- **Cert expiry**: mkcert certs last ~825 days — re-run any `setup.sh` to regenerate.
- **`nginx -s reload` fails with `kill(...) failed (1: Operation not permitted)`** (and `nginx -t` on the root-owned pid file): the master runs as root — use `sudo`.
- **Browser "Not secure"** / **`ERR_CERT_COMMON_NAME_INVALID`**: CA not trusted (run `mkcert -install`, restart browser), or the domain isn't in the SAN list yet (re-run `setup.sh` for it).
- **OAuth provider rejects the URL**: the registered `redirect_uri` must match `https://<domain>/<path>` exactly.
- **Next.js "blocked cross-origin request"**: auto-injection missed an unusual `next.config` shape — add `allowedDevOrigins: ['<domain>']` manually.
- **iOS Simulator shows "This Connection Is Not Private"**: DNS works in the sim (it inherits the host's resolution, including `/etc/resolver`), but `mkcert -install` does not touch simulator trust stores. One-time per simulator: `xcrun simctl keychain booted add-root-cert "$(mkcert -CAROOT)/rootCA.pem"`.
- **Loads on the Mac but not another LAN device**: it's private — re-run with `--shared` (flips DNS → LAN IP and drops `deny all`). The device still needs this Mac as resolver and the mkcert CA trusted.
- **A `--shared` domain 403s from the Mac itself**: DNS resolves to the LAN IP but the block still has `deny all`. Re-run `--shared` to rewrite both consistently.
- **`--shared` domain stopped resolving after a network change**: the `address=/<domain>/<LAN IP>` line is pinned — re-run `--shared` on the new network to repin. If dnsmasq itself is down (`pgrep dnsmasq` empty), a legacy `listen-address=<LAN IP>` line is the cause: replace it with `interface=en0`.

## Tearing down a domain

```bash
~/.claude/skills/local-https-domain/scripts/teardown.sh <domain>
sudo brew services restart nginx
sudo brew services restart dnsmasq      # only if the domain had a dnsmasq override
```

Removes the nginx config + any per-domain dnsmasq override, regenerates `local-dev.pem` without the domain (deletes the cert files if none remain). A shared domain's `listen-address=<LAN_IP>` line is left in place — harmless, and may still serve other shared domains.
