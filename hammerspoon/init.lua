function reloadConfig(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "l", function()
	hs.window.focusedWindow():focusWindowEast(nil, true)
end)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "h", function()
	hs.window.focusedWindow():focusWindowWest(nil, true)
end)

local apps = {
	F6 = "Google Chrome",
	F7 = "Ghostty",
	F8 = "Slack",
}

for key, app in pairs(apps) do
	hs.hotkey.bind({}, key, function()
		hs.application.launchOrFocus(app)
	end)
end

pcall(require, "local")
