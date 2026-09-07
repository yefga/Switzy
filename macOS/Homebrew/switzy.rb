cask "switzy" do
  version "1.2.0"
  sha256 "4a7e1c0d94a13ee83644a385fb1d73430d183877e91962fab9297d83608074d4"

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
