class ForgeWeb < Formula
  desc "Web UI for Forge VCS, a version control system for Unreal Engine"
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
    # The release tarball is shared with the sibling `forge-server`
    # formula. This formula owns only the web UI half: the forge-web
    # binary, the prebuilt React bundle, and the forge-web config. The
    # gRPC server lives in forge-server so each component has its own
    # `brew services` lifecycle.
    bin.install "forge-web"
    (share/"forge").install "ui"

    # Non-destructive config install. Rewrite the shipped relative paths
    # (`./ui`, `./forge-data/certs/ca.crt`) to absolute Brew prefixes so
    # the daemon doesn't depend on launchd's working directory, which
    # isn't guaranteed.
    (etc/"forge").mkpath

    unless (etc/"forge/forge-web.toml").exist?
      cfg = File.read("forge-web.toml")
      cfg.gsub!('static_dir = "./ui"', "static_dir = \"#{share}/forge/ui\"")
      cfg.gsub!('ca_cert_path = "./forge-data/certs/ca.crt"',
                "ca_cert_path = \"#{var}/forge/certs/ca.crt\"")
      (etc/"forge/forge-web.toml").write cfg
    end
  end

  def caveats
    <<~EOS
      Forge web UI installed.

        Config:  #{etc}/forge/forge-web.toml
        Assets:  #{share}/forge/ui

      Start the web UI:
        brew services start forge-web

      The web UI listens on https://0.0.0.0:3000 by default and talks to
      a forge-server over gRPC. The shipped config points at
      https://127.0.0.1:9876 and trusts the self-signed CA that
      forge-server writes at #{var}/forge/certs/ca.crt, so the usual
      setup is to also install the sibling formula:

        brew install kasaiarashi/forge/forge-server
        brew services start forge-server

      To drive a remote forge-server instead, edit grpc_url and
      ca_cert_path in #{etc}/forge/forge-web.toml.
    EOS
  end

  service do
    run [opt_bin/"forge-web", "--config", etc/"forge/forge-web.toml"]
    keep_alive true
    log_path var/"log/forge-web.log"
    error_log_path var/"log/forge-web.log"
  end

  test do
    assert_match "forge-web", shell_output("#{bin}/forge-web --help")
  end
end
