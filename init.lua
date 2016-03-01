local awful = require("awful")
local screen = screen
local client = client
local tag = tag
local mouse = mouse
local ipairs = ipairs

module("awesome-remember-geometry")

-- {{{ Remember client size when switching between floating and tiling.
local floatingwindows = {}

tag.connect_signal("property::layout", function(t)
	for k, c in ipairs(t:clients()) do
		if floatingwindows[c.window] and isFloatingClient(c) then
			c:geometry(floatingwindows[c.window].geometry)
		end
	end
end)

client.add_signal("maximize")
client.connect_signal("maximize", function(c)
	if not floatingwindows[c.window] then
		floatingwindows[c.window] = {}
	end
	-- max if
	--- both are false
	--- only one is true
	local maxh = c.maximized_horizontal
	local maxv = c.maximized_vertical
	local max = (not maxh and not maxv) or not (maxh and maxv)
	floatingwindows[c.window].manual_max = max
	c.maximized_horizontal = max
	c.maximized_vertical = max
end)

client.connect_signal("unmanage", function(c) 
floatingwindows[c.window] = nil
end)

client.connect_signal("manage", function(c)
if isFloatingClient(c) and c.minimized == false then
	floatingwindows[c.window]={geometry=c:geometry()}
end
end)

client.connect_signal("property::geometry", function(c)
if isFloatingClient(c) and c.fullscreen == false and c.minimized == false then
	if not floatingwindows[c.window] then
		floatingwindows[c.window] = {}
	end
	-- if client is almost maximized then set it to maximized.
	-- if client was maximized before allow to go back to normal view.
	cgeometry = c:geometry()
	sgeometry = screen[c.screen].workarea
	floatingwindows[c.window].geometry = cgeometry
	if c.maximized_horizontal == false then
		diffWidth = sgeometry.width - cgeometry.width - c.border_width
		xpos = sgeometry.x - cgeometry.x
		if not floatingwindows[c.window].auto_max_width and diffWidth == 0 and xpos == 0 then
			floatingwindows[c.window].auto_max_width = true
			c.maximized_horizontal = true
		else
			floatingwindows[c.window].auto_max_width = false
		end
	end
	if c.maximized_vertical == false then
		diffHeight = sgeometry.height - cgeometry.height - c.border_width
		ypos = sgeometry.y - cgeometry.y
		if not floatingwindows[c.window].auto_max_height and diffHeight == 0 and ypos == 0 then
			floatingwindows[c.window].auto_max_height = true
			c.maximized_vertical = true
		else
			floatingwindows[c.window].auto_max_height = false
		end
	end
end
end)

client.connect_signal("property::fullscreen", function(c)
if isFloatingClient(c) and floatingwindows[c.window] and c.fullscreen == false then
	c:geometry(floatingwindows[c.window].geometry)
	if floatingwindows[c.window].manual_max then
		c.maximized_horizontal = true
		c.maximized_vertical = true
	end
end
end)

function isFloatingClient(c)
	return (awful.layout.get(mouse.screen) == awful.layout.suit.floating) or (awful.client.floating.get(c) == true)
end
-- }}}
