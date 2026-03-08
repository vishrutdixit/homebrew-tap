class Bonk < Formula
  desc "LLM-powered spaced repetition CLI for technical interview prep"
  homepage "https://github.com/vishrutdixit/bonk"
  version "0.3.19"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.19/bonk-darwin-arm64.tar.gz"
      sha256 "e23b20365e02eb06b09e7e2640a4175e7a44776e21ed98a88c4945af34b6f672"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.19/bonk-darwin-amd64.tar.gz"
      sha256 "4114d77bacc7e1e983236ef462d391bf24ffdc98c4ef90c756e71f827369cd46"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.19/bonk-linux-arm64.tar.gz"
      sha256 "758f2a51379f0ae82fa7460208546ffe9e8859c2dc061de9f7edd9f6ec73d273"
    end
    on_intel do
      url "https://github.com/vishrutdixit/bonk/releases/download/v0.3.19/bonk-linux-amd64.tar.gz"
      sha256 "0bd72779eabc1f0c7fa8e55c4533c513853f682fc81950b3cc054a335988ac24"
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
