class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.2/bonk-darwin-arm64.tar.gz"
      sha256 "2b186d37ba92bb0316498d349b8467abbd7b8e3dfb109bb68be5ee376ff6e578"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.2/bonk-darwin-amd64.tar.gz"
      sha256 "033f6e4c480c61cdf29f19d7e57c0db63a1fe8018b5fb933516ce4a41c7c9ef4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.2/bonk-linux-arm64.tar.gz"
      sha256 "334f49ea201b1b039c3ebb659244ad909f02fd6f5992b3274b1fa9e7370b4231"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.2/bonk-linux-amd64.tar.gz"
      sha256 "676f0f78fb6dc5a5073f296d49f05ab5fb2db18841ba5eb7b75b4b6e06235ee6"
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
