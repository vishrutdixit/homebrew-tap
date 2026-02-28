class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.8"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.8/bonk-darwin-arm64.tar.gz"
      sha256 "513700a1ca33732b5fe08b8946de34152b587d945616866934144bf8e221c7bc"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.8/bonk-darwin-amd64.tar.gz"
      sha256 "7c981fc4fca176b097ff4c5a122e2c1f67bf838f612b623b323970e43033bff4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.8/bonk-linux-arm64.tar.gz"
      sha256 "e7c802c0b6f178759a0e61648c9d318ba456ef589a0c3c1919ec467fa83f4fb1"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.8/bonk-linux-amd64.tar.gz"
      sha256 "b9bda1532ceb98a5fb98f26cc0f6e3bdc4d198edd7786363d6cf6f6e963c6cf0"
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
