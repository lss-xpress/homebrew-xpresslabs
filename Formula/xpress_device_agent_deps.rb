class XpressDeviceAgentDeps < Formula
  desc "Dependencies for XpressDeviceAgentDeps"
  homepage "https://xpress-labs.com"
  version "1.0.0"

  # Declare the required dependencies
  depends_on "usbmuxd" => :head
  depends_on "libimobiledevice" => :head
  depends_on "ideviceinstaller" => :head
  depends_on "libplist" => :head
  depends_on "jq"
  depends_on "unzip"
  depends_on "zip"
  depends_on "carthage"
  depends_on "imagemagick"
  depends_on "ffmpeg"
  depends_on "px"
  depends_on "opencv"
  depends_on "android-commandlinetools"

  def install
    # Since dependencies are automatically handled by Homebrew,
    # no additional install commands are needed here.
  end

  def post_install
    # Perform additional linking and setup commands if needed
    system "brew", "link", "--overwrite", "libimobiledevice"
    system "brew", "link", "--overwrite", "ideviceinstaller"
  end

  test do
    # Optional: Add tests to verify the installation
    assert_match "usage", shell_output("ffmpeg -version")
    assert_match "usage", shell_output("opencv_version")
    assert_match "usage", shell_output("usbmuxd -h")
  end
end
