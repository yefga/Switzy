cask "switzy" do
  version "0.1.0"
  sha256 :no_check # Replace with actual sha256 of the dmg

  url "https://github.com/yefga/Switzy/releases/download/v#{version}/Switzy-v#{version}.dmg"
  name "Switzy"
  desc "Git Identity Manager"
  homepage "https://github.com/yefga/Switzy"

  app "Switzy.app"

  zap trash: [
    "~/Library/Application Support/com.yefga.Switzy",
    "~/Library/Preferences/com.yefga.Switzy.plist",
    "~/Library/Saved Application State/com.yefga.Switzy.savedState",
  ]
end
