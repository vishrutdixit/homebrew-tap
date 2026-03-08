class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.18"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.18/bonk-darwin-arm64.tar.gz"
      sha256 "60f85ead1bdbf959a14aa9d896b61df66d13991f2dcf8ffa301dbf3f5ff1df21"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.18/bonk-darwin-amd64.tar.gz"
      sha256 "ed28f28731a8d83ba0fb324e777d72635913693c44fdc8c7a309d9b2d74e1fb5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.18/bonk-linux-arm64.tar.gz"
      sha256 "cbe31a662ed5eafc35a6a498e8d13a2c056b1b500f38dbcfe3c5a0d00febfa5c"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.18/bonk-linux-amd64.tar.gz"
      sha256 "6a72c0d021ec31f3ccc1e0e690e8c36aa3be314684f2d0a4f7e6180129d0e76b"
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
