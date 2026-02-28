class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.3/bonk-darwin-arm64.tar.gz"
      sha256 "d3aee3eb3b7537ab41ab0df8706b3440b08b6a4caddc73cfb24e0e6f56bdb360"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.3/bonk-darwin-amd64.tar.gz"
      sha256 "dc92af06eb8f9f86d8b0ef1ee714ffa7c4877e833632307e5ed549cec2869cc3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.3/bonk-linux-arm64.tar.gz"
      sha256 "1683e264e7750e8ef1750f452389207cf354853b1980a88ed51ef0d1fd3e82d2"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.3/bonk-linux-amd64.tar.gz"
      sha256 "ff0bde82929b4da63dfa9aacc38fc59cf0820a339bc40a76afb0b177cf434637"
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
