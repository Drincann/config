hs.hotkey.bind({"shift", "cmd" }, "h", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f, 0.15)
end)

hs.hotkey.bind({"shift", "cmd" }, "l", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x + max.w / 2
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f, 0.15)
end)

hs.hotkey.bind({"shift", "cmd" }, "k", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f, 0.15)
end)

hs.hotkey.bind({"shift", "cmd" }, "j", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x
  f.y = max.y + max.h / 2
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f, 0.15)
end)

hs.hotkey.bind({"shift", "cmd" }, "f", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:toggleFullScreen()
end)

hs.hotkey.bind({"option", "shift", "cmd" }, "c", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:centerOnScreen()
end)

-- next window
hs.hotkey.bind({"shift", "cmd" }, "'", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:focusWindowEast()
end)

-- previous window
hs.hotkey.bind({"shift", "cmd" }, ";", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:focusWindowWest()
end)

-- top left
hs.hotkey.bind({"shift", "cmd" }, "u", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f, 0.15)
end)

-- top right
hs.hotkey.bind({"shift", "cmd" }, "o", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x + max.w / 2
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f, 0.15)
end)

-- bottom left
hs.hotkey.bind({"shift", "cmd" }, "m", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x
  f.y = max.y + max.h / 2
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f, 0.15)
end)

-- bottom right
hs.hotkey.bind({"shift", "cmd" }, ".", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x + max.w / 2
  f.y = max.y + max.h / 2
  f.w = max.w / 2
  f.h = max.h / 2
  win:setFrame(f, 0.15)
end)

-- full screen
hs.hotkey.bind({"shift", "cmd" }, "i", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local max = win:screen():frame()
  local f = win:frame()
  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f, 0.15)
end)

-- bigger
hs.hotkey.bind({"option", "shift", "cmd" }, "=", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.w = f.w * 1.1
  f.h = f.h * 1.1
  -- position
  f.x = f.x - (f.w * 0.05)
  f.y = f.y - (f.h * 0.05)

  win:setFrame(f, 0.15)
end)

-- smaller
hs.hotkey.bind({"option", "shift", "cmd" }, "-", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.w = f.w * 0.9
  f.h = f.h * 0.9
  -- position
  f.x = f.x + (f.w * 0.05)
  f.y = f.y + (f.h * 0.05)
  win:setFrame(f, 0.15)
end)

-- x expand
hs.hotkey.bind({"option", "shift", "cmd" }, "'", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.w = f.w * 1.1
  -- position
  f.x = f.x - (f.w * 0.05)
  win:setFrame(f, 0.15)
end)

-- x shrink
hs.hotkey.bind({"option", "shift", "cmd" }, ";", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.w = f.w * 0.9
  -- position
  f.x = f.x + (f.w * 0.05)
  win:setFrame(f, 0.15)
end)

-- y expand
hs.hotkey.bind({"option", "shift", "cmd" }, "p", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.h = f.h * 1.1
  -- position
  f.y = f.y - (f.h * 0.05)
  win:setFrame(f, 0.15)
end)

-- y shrink
hs.hotkey.bind({"option", "shift", "cmd" }, "/", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.h = f.h * 0.9
  -- position
  f.y = f.y + (f.h * 0.05)
  win:setFrame(f, 0.15)
end)

-- x position left
hs.hotkey.bind({"option", "shift", "cmd" }, "h", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.x = f.x - (f.w * 0.1)
  win:setFrame(f, 0.15)
end)

-- x position right
hs.hotkey.bind({"option", "shift", "cmd" }, "l", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.x = f.x + (f.w * 0.1)
  win:setFrame(f, 0.15)
end)

-- y position up
hs.hotkey.bind({"option", "shift", "cmd" }, "k", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.y = f.y - (f.h * 0.1)
  win:setFrame(f, 0.15)
end)

-- y position down
hs.hotkey.bind({"option", "shift", "cmd" }, "j", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local f = win:frame()
  f.y = f.y + (f.h * 0.1)
  win:setFrame(f, 0.15)
end)
