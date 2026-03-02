class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.13"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.13/bonk-darwin-arm64.tar.gz"
      sha256 "b66975d8713896be172e1a66e1479cf1d32de627ecab33703080d06c23d07bca"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.13/bonk-darwin-amd64.tar.gz"
      sha256 "7cf791fc08d83b67c1e9b36c9a347b901e684bbc044459d3eda92b2a932c7bf0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.13/bonk-linux-arm64.tar.gz"
      sha256 "754cb1b496fa5b0dc2f7553636945fe17fd9a847e69c46af12cf0d4fddeae882"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.13/bonk-linux-amd64.tar.gz"
      sha256 "15b890066da87c9426d3bfa4171dec49e5837aa8ae63e75947acc61ed1b28838"
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
