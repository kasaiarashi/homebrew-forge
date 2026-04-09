# homebrew-forge

Homebrew tap for [Forge VCS](https://github.com/kasaiarashi/forge) — a version control system built in Rust, purpose-built for Unreal Engine game development.

## Install

```bash
brew install kasaiarashi/forge/forge-server
```

Then start the daemon:

```bash
brew services start forge-server
```

The server listens on port `9876` and serves both the gRPC and web UI endpoints over the same self-signed TLS certificate (auto-generated on first start).

## Layout

| | Path |
|---|---|
| Binaries | `$(brew --prefix)/bin/forge-server`, `forge-web` |
| Config | `$(brew --prefix)/etc/forge/forge-server.toml` |
| Data | `$(brew --prefix)/var/forge/` |
| Web UI assets | `$(brew --prefix)/share/forge/ui/` |
| Logs | `$(brew --prefix)/var/log/forge-server.log` |

The default config uses an absolute `base_path`, so the daemon's data directory is stable regardless of how launchd or `brew services` invokes it.

## Updating

```bash
brew update
brew upgrade forge-server
```

## Available formulas

| Formula | What it installs |
|---|---|
| `forge-server` | The Forge VCS server (`forge-server`) and web UI server (`forge-web`) for self-hosting a repo |

## Links

- [Main project](https://github.com/kasaiarashi/forge)
- [Releases](https://github.com/kasaiarashi/forge/releases)
- [Issues](https://github.com/kasaiarashi/forge/issues)
