class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.6/bonk-darwin-arm64.tar.gz"
      sha256 "e8fc16e52088bd69e0dbd4c70dfb3f5892f4bf4d939f884d35e1860ca5fd8f91"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.6/bonk-darwin-amd64.tar.gz"
      sha256 "689eb502e40f30e9f80a760af48c3561670ca872e34dd51defbbc71701e5b3d8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.6/bonk-linux-arm64.tar.gz"
      sha256 "fdb12e060d8b5585955f17d0dda063c4620779b5e5a3dc5ed0e8d4f3be2092c4"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.6/bonk-linux-amd64.tar.gz"
      sha256 "413d5937e8f7a16c5a51d4886489f6bdd947489b9ccb432db4b6d10818ef9f4b"
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
