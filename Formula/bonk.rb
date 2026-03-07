class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.14"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.14/bonk-darwin-arm64.tar.gz"
      sha256 "46151167073729fc148afc8c0262556926a116d49f1f503e0e620bad0bd3dc7c"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.14/bonk-darwin-amd64.tar.gz"
      sha256 "7ed90e5291020f0ec04844ff5ed9d152a59118f31e2d2e28c9d7207c48e15a77"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.14/bonk-linux-arm64.tar.gz"
      sha256 "50f1d1c65223eb414a22a8d5c23c75d853b0424cbe00c62ac6d44d3acf98f45d"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.14/bonk-linux-amd64.tar.gz"
      sha256 "e2929b3be283c30262df65da80a737e6be776fb13e15f43bdcd3efb4712dbe23"
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
