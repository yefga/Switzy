cask "switzy" do
  version "1.3.0"
  sha256 "e7908e075bd128332057cc6abf39c6343b5bafecc736a9e265c2d6458df5941d"

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
