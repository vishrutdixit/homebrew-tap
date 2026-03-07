class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.17"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.17/bonk-darwin-arm64.tar.gz"
      sha256 "8ddb327daff6fd08fd86030896442ccffca31d0c93223afe341a9c81a311d29d"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.17/bonk-darwin-amd64.tar.gz"
      sha256 "fb37ff97474d3dd7dacdc9e244bd1786b1f15ff8f2b0a5d6fd4d0f0c34dc295e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.17/bonk-linux-arm64.tar.gz"
      sha256 "4d64ed2d33332d21af7b188187e4a9df9f355f25e0a819ffb1a12399a9a09de6"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.17/bonk-linux-amd64.tar.gz"
      sha256 "a9f537c595cbcb71e3a39d086c4a3e9fb30b9186e923a4143becaec1af1e3b27"
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
