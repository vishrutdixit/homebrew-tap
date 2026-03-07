class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.15"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.15/bonk-darwin-arm64.tar.gz"
      sha256 "12aba885d1d161de1d8ed1fd688210648945f80aae84b07594ed428af89e7541"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.15/bonk-darwin-amd64.tar.gz"
      sha256 "eeea1cf9d59f30df8a1765b0f18b1abf48b641de38c567dc67cdca58900de79f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.15/bonk-linux-arm64.tar.gz"
      sha256 "4c95442faac9430f796998677cffeb99867ccc9ccfed099c6f4cc6883a7cf719"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.15/bonk-linux-amd64.tar.gz"
      sha256 "98a5ea2c0ccbea1c0ccd666408cad5d93a1266f1304cd6d2fa0484b3a5e615e3"
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
