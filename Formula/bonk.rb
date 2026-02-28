class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.5/bonk-darwin-arm64.tar.gz"
      sha256 "2c5f7e08e5d90832c4513417b8a16a661d1d56084943e60eca7058fabe566c45"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.5/bonk-darwin-amd64.tar.gz"
      sha256 "07fd902a7d7483365c42eb3e0b53d3ba0f92935149a3f8d1a646ddc22dbbac0e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.5/bonk-linux-arm64.tar.gz"
      sha256 "4103f778abb219dedc4f4ae52927c4a9cffbb8baf15ba68b20da19bef57edfce"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.5/bonk-linux-amd64.tar.gz"
      sha256 "becdae85585be56a55e5d80071210ccf9398a53e39376923ef109fe671b82745"
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
