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
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/sources/nixos/hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

hs.hotkey.bind({ "cmd" }, "l", function()
  hs.window.filter.default:focusWindowEast(nil, true)
end)
hs.hotkey.bind({ "cmd" }, "h", function()
  hs.window.filter.default:focusWindowWest(nil, true)
end)

pcall(require, "local")
