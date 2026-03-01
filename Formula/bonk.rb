class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.12"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.12/bonk-darwin-arm64.tar.gz"
      sha256 "471441a7e67a25fe852cdf85904127bcb381ea450b32f78dcbda0595417325e7"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.12/bonk-darwin-amd64.tar.gz"
      sha256 "164e4c5437538246f3f5b13740858d03be3bd365db6219a9892f6623b5c3e123"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.12/bonk-linux-arm64.tar.gz"
      sha256 "911277757b42a58671e2e7241a7343f2cf030f3fce87e283c85324ca7ee7a26c"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.12/bonk-linux-amd64.tar.gz"
      sha256 "e95388cf6263c910c8eb9c9382d9479f2f798bd8f3cfe2c8a9ade805ed3090f7"
    end
  end

  depends_on "sox" => :recommended
  depends_on "whisper-cpp" => :recommended

  def install
    binary_name = "bonk-#{OS.kernel_name.downcase}-#{Hardware::CPU.arch == :arm64 ? "arm64" : "amd64"}"
    bin.install binary_name => "bonk"
  end

  def post_install
    (var/"bonk").mkpath
    if OS.mac? && build.with?("whisper-cpp")
      bonk_dir = Pathname.new(Dir.home)/".bonk"
      bonk_dir.mkpath
      model_path = bonk_dir/"ggml-tiny.en.bin"
      unless model_path.exist?
        ohai "Downloading whisper model for voice mode..."
        system "curl", "-sSL",
          "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin",
          "-o", model_path
      end
    end
  end

  def caveats
    <<~EOS
      To use bonk, you need an Anthropic API key:
        export ANTHROPIC_API_KEY="your-key-here"

      Start drilling:
        bonk

      Voice mode (macOS):
        bonk --voice
    EOS
  end

  test do
    assert_match "bonk", shell_output("#{bin}/bonk --version")
  end
end
