class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.4/bonk-darwin-arm64.tar.gz"
      sha256 "de08b6176a2078443c410deacbc08499597e743216faf186466b46c4aa72c66b"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.4/bonk-darwin-amd64.tar.gz"
      sha256 "547af9a119f4160085d8c32142005ac4466bfb14b7a9177e01daaaa683ac0095"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.4/bonk-linux-arm64.tar.gz"
      sha256 "048384b6b0f329100da5faaccc8a44b6d754f462c68a2559ff2fe5682d613ad4"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.4/bonk-linux-amd64.tar.gz"
      sha256 "e5bded70b207061434cfc2dba58693ada1b2165dc9645ecfdcfc7cce3fa59cc7"
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
