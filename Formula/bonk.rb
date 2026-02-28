class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.7"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.7/bonk-darwin-arm64.tar.gz"
      sha256 "5e5af50e082f6b388129f664b8b10696076b9e879107599b67a7f63a6a367ee7"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.7/bonk-darwin-amd64.tar.gz"
      sha256 "f071d894b5a621199a176ff53a79ebc9501a68f479e766933e0a07de29bf91cb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.7/bonk-linux-arm64.tar.gz"
      sha256 "43c2c82564a127904ec883bfd49cafa59c34eb394425e53b77cbf549f987fdb6"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.7/bonk-linux-amd64.tar.gz"
      sha256 "b9bbce365ac05b21b8e44d236311221b37ddb49b75824f5079723e6b4b6532a4"
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
