class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.9"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.9/bonk-darwin-arm64.tar.gz"
      sha256 "60f0232eac1e97b47a4dff8fa67c17a6962086770818e5a12298bf627cdd346a"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.9/bonk-darwin-amd64.tar.gz"
      sha256 "5c8853019b75c2ead4dd7047ef96eede222be12fa16034e21b2a38926871d6eb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.9/bonk-linux-arm64.tar.gz"
      sha256 "2eb392cb97366c2381696c59f78b737889ab3aadeae61af54cadc7fd44259abf"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.9/bonk-linux-amd64.tar.gz"
      sha256 "25f16719bc45e089a3cc36350a313899525f867fe5450c2f1c9e5488256b3923"
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
