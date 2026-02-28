class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.10"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.10/bonk-darwin-arm64.tar.gz"
      sha256 "b25cb220d3f10959936399e8b5e32c750621598cc4e8cafa4a652fa91f6c7967"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.10/bonk-darwin-amd64.tar.gz"
      sha256 "c73aed1d832f12da79c3c82f25c4b31722868f0f774f8e83b6a51eb8d4b66edd"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.10/bonk-linux-arm64.tar.gz"
      sha256 "5b9373068156e09eda7d822ff8658c13ad3cb44fed6ff80150635183afbd0884"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.10/bonk-linux-amd64.tar.gz"
      sha256 "5443cc23c7a53117b582b15814b40bad990f143766d9d1deabac80990b256af3"
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
