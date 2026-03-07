class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.16"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.16/bonk-darwin-arm64.tar.gz"
      sha256 "4e127e02f6270d30174199dae14c301b8947ef43ce0767eefaf90727197394d3"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.16/bonk-darwin-amd64.tar.gz"
      sha256 "16b23b8d96a886c17a03248b6d366e17c77f120acddcac6b68fcc324bb009e11"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.16/bonk-linux-arm64.tar.gz"
      sha256 "2f1aa2031f1b6be4bfc0b027cbe29ab5852d5f9fe60a9739257664a3228c42e4"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.16/bonk-linux-amd64.tar.gz"
      sha256 "fb8a0594d6b45d9bcf9975505fbc3b2318f15133269f3c5c9837707af3e030bb"
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
