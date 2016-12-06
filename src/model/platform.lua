local platform = {}

platform.name = system.getInfo("platformName")

local function getAudioFormat()
	if platform.name == platform.ANDROID or platform.name == platform.WINDOWS then
		return ".wav"
	else
		return ".aif"
	end
end

platform.MAC = "Mac OS X"
platform.WINDOWS = "Win"
platform.WINDOWS_PHONE = "WinPhone"
platform.IOS = "iPhone OS"
platform.ANDROID = "Android"

platform.audioFormat = getAudioFormat()

return platform