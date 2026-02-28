class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.11"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.11/bonk-darwin-arm64.tar.gz"
      sha256 "d57574c40fcf9859fb463f9ddd3aa52d29798094a305d1772a5c4a9852c93cf9"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.11/bonk-darwin-amd64.tar.gz"
      sha256 "7630bfdd1536bbac1e7b2dbdcc367c5e42633009266081529d46727745e7c672"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.11/bonk-linux-arm64.tar.gz"
      sha256 "09a6f50a67c57396ad53d5596dd106f955e05259802865d74a916ba67dd759dc"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.11/bonk-linux-amd64.tar.gz"
      sha256 "b02355fd3ed42b2e3c0c5dab2affa60c5b8a0b74427bcaa53c3b51156ded1975"
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
