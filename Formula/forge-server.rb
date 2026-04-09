class ForgeServer < Formula
  desc "Version control system built for Unreal Engine game development (server)"
  homepage "https://github.com/kasaiarashi/forge"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/kasaiarashi/forge/releases/download/v0.1.0/forge-server-macos-arm64.tar.gz"
      sha256 "46fe9e112412ac7c0f14f478853da08cff8842f9907a5bc42d58cba3aa727127"
    end
    on_intel do
      url "https://github.com/kasaiarashi/forge/releases/download/v0.1.0/forge-server-macos-amd64.tar.gz"
      sha256 "6f8921c12b7b26a90024342dd44fb3519a3578cc1a1e5d7504378a602d8e02f4"
    end
  end

  def install
    # The release tarballs ship with two binaries plus a UI bundle and
    # a pair of config templates. Brew strips the leading
    # `forge-server-macos-*/` directory by default, so the working tree
    # already has these at the top level.
    bin.install "forge-server"
    bin.install "forge-web"
    (share/"forge").install "ui"

    # Install config templates non-destructively into HOMEBREW_PREFIX/etc.
    # The templates ship with `./forge-data` as a relative `base_path`,
    # which is fragile under launchd because the working directory isn't
    # guaranteed. We rewrite it to an absolute path under
    # HOMEBREW_PREFIX/var/forge so the data dir is stable regardless of
    # how the daemon is started.
    (etc/"forge").mkpath
    (var/"forge").mkpath

    unless (etc/"forge/forge-server.toml").exist?
      cfg = File.read("forge-server.toml")
      cfg.gsub!('base_path = "./forge-data"', "base_path = \"#{var}/forge\"")
      (etc/"forge/forge-server.toml").write cfg
    end

    unless (etc/"forge/forge-web.toml").exist?
      cfg = File.read("forge-web.toml")
      cfg.gsub!('static_dir = "./ui"', "static_dir = \"#{share}/forge/ui\"")
      (etc/"forge/forge-web.toml").write cfg
    end
  end

  def caveats
    <<~EOS
      Forge server installed.

        Config:  #{etc}/forge/forge-server.toml
        Data:    #{var}/forge
        Web UI:  #{share}/forge/ui

      Start the daemon:
        brew services start forge-server

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
