class ForgeServer < Formula
  desc "Version control system built for Unreal Engine game development (server)"
  homepage "https://github.com/kasaiarashi/forge"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kasaiarashi/forge/releases/download/v0.1.0/forge-server-macos-arm64.tar.gz"
      sha256 "89700a4a005f534a7ff1f0267db05732781cc97bba4d5e575102ee3caf0d5ffc"
    end
    on_intel do
      url "https://github.com/kasaiarashi/forge/releases/download/v0.1.0/forge-server-macos-amd64.tar.gz"
      sha256 "27e4ecf4f08247f2205fb9682d0d318cb1d29bdbcb3d5471ae8ec48c6f2a317f"
    end
  end

  def install
    # The release tarball is shared with the sibling `forge-web` formula
    # and ships both binaries, the UI bundle, and both config templates.
    # This formula only owns the gRPC server half so each component has
    # its own `brew services` lifecycle.
    bin.install "forge-server"

    # Install the config template non-destructively into etc. The shipped
    # template uses `./forge-data` as a relative `base_path`, which is
    # fragile under launchd because the working directory isn't
    # guaranteed. Rewrite it to an absolute path under var/forge so the
    # data dir is stable regardless of how the daemon is started.
    (etc/"forge").mkpath
    (var/"forge").mkpath

    unless (etc/"forge/forge-server.toml").exist?
      cfg = File.read("forge-server.toml")
      cfg.gsub!('base_path = "./forge-data"', "base_path = \"#{var}/forge\"")
      (etc/"forge/forge-server.toml").write cfg
    end
  end

  def caveats
    <<~EOS
      Forge VCS server installed.

        Config:  #{etc}/forge/forge-server.toml
        Data:    #{var}/forge

      Start the daemon:
        brew services start forge-server

      To also run the web UI, install the sibling formula:
        brew install kasaiarashi/forge/forge-web
        brew services start forge-web

      Then point clients at https://<this-host>:9876 and run `forge login`.
      The first client connection will show the self-signed CA fingerprint
      from the server's startup log — verify they match before accepting.
    EOS
  end

  service do
    run [opt_bin/"forge-server", "serve", "--config", etc/"forge/forge-server.toml"]
    keep_alive true
    log_path var/"log/forge-server.log"
    error_log_path var/"log/forge-server.log"
  end

  test do
    assert_match "forge-server", shell_output("#{bin}/forge-server --help")
  end
end
