# homebrew-forge

Homebrew tap for [Forge VCS](https://github.com/kasaiarashi/forge) — a version control system built in Rust, purpose-built for Unreal Engine game development.

## Install

The tap ships two formulas — the gRPC server and the web UI. Most self-hosted setups want both:

```bash
brew install kasaiarashi/forge/forge-server
brew install kasaiarashi/forge/forge-web

brew services start forge-server
brew services start forge-web
```

`forge-server` listens on port `9876` (gRPC) and `forge-web` on port `3000` (HTTPS). Both auto-generate self-signed TLS certificates on first start. The default `forge-web` config trusts `forge-server`'s CA, so installing both side-by-side Just Works.

If you only need the web UI pointed at a remote `forge-server`, install `forge-web` alone and edit `grpc_url` / `ca_cert_path` in its config.

## Layout

| | Path |
|---|---|
| Binaries | `$(brew --prefix)/bin/forge-server`, `$(brew --prefix)/bin/forge-web` |
| Server config | `$(brew --prefix)/etc/forge/forge-server.toml` |
| Web config | `$(brew --prefix)/etc/forge/forge-web.toml` |
| Data | `$(brew --prefix)/var/forge/` |
| Web UI assets | `$(brew --prefix)/share/forge/ui/` |
| Server logs | `$(brew --prefix)/var/log/forge-server.log` |
| Web logs | `$(brew --prefix)/var/log/forge-web.log` |

The default configs use absolute paths, so both daemons' data and asset directories are stable regardless of how launchd or `brew services` invokes them.

## Updating

```bash
brew update
brew upgrade forge-server forge-web
```

## Available formulas

| Formula | What it installs |
|---|---|
| `forge-server` | The Forge VCS gRPC server (`forge-server`) for self-hosting a repo |
| `forge-web` | The Forge VCS web UI (`forge-web` + React bundle) |

## Links

- [Main project](https://github.com/kasaiarashi/forge)
- [Releases](https://github.com/kasaiarashi/forge/releases)
- [Issues](https://github.com/kasaiarashi/forge/issues)
