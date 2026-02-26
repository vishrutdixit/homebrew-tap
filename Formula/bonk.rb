class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.0/bonk-darwin-arm64.tar.gz"
      sha256 "da8894f6d4b0783c5c3dca0c44fcc32b6777ba6c6bfb8955923bce87f44346af"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.0/bonk-darwin-amd64.tar.gz"
      sha256 "7a894b8bbeed45ae73f02b57b1009d3257792d455649bf30f8f8c8a78c080bb1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.0/bonk-linux-arm64.tar.gz"
      sha256 "92aae135ee81efceb9ae1875ae101201239dc9e46f86567e31dc7a985e684dcd"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.0/bonk-linux-amd64.tar.gz"
      sha256 "97a612a3a9fc2a6fbaaf2e344fb5b12873addf88441424e43d17179416d17793"
    end
  end

  # Voice mode dependencies (optional but recommended on macOS)
  depends_on "sox" => :recommended
  depends_on "whisper-cpp" => :recommended

  def install
    # Binary name in archive includes platform suffix
    binary_name = "bonk-#{OS.kernel_name.downcase}-#{Hardware::CPU.arch == :arm64 ? "arm64" : "amd64"}"
    bin.install binary_name => "bonk"
  end

  def post_install
    # Create bonk directory for data
    (var/"bonk").mkpath

    # Download whisper model for voice mode (macOS only)
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
        - Press space to record your answer
        - Press 's' to skip text-to-speech

      If voice mode isn't working, run:
        bonk setup
    EOS
  end

  test do
    assert_match "bonk", shell_output("#{bin}/bonk --version")
  end
end
