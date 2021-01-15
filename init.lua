local awful = require("awful")
local client = client
local tag = tag
local ipairs = ipairs

-- {{{ Remember client size when switching between floating and tiling.
client.connect_signal("maximize", function(c)
	-- max if
	--- both are false
	--- only one is true
	local max_h = c.maximized_horizontal
	local max_v = c.maximized_vertical
	local max = (not max_h and not max_v) or not (max_h and max_v)
	c.remember_geometry.maximized_manual = max
	c.maximized_horizontal = max
	c.maximized_vertical = max
	c.maximized = max
end)

client.connect_signal("manage", function(c)
c.remember_geometry = {
	floating_geometry=c:geometry(),
	maximized_manual=false,
	maximized_horizontal=c.maximized_horizontal,
	maximized_vertical=c.maximized_vertical
}
end)

client.connect_signal("unmanage", function(c)
c.remember_geometry = nil
end)

client.connect_signal("property::floating", function(c)
if c.floating and c.remember_geometry then
	c:geometry(c.remember_geometry.floating_geometry)
end
end)

tag.connect_signal("property::layout", function(t)
if t.layout == awful.layout.suit.floating then
	for k, c in ipairs(t:clients()) do
		c:geometry(c.remember_geometry.floating_geometry)
	end
end
end)

client.connect_signal("request::geometry", function(c, context)
if context == "mouse.resize" and not c.fullscreen then
	c.maximized_horizontal = false
	c.maximized_vertical = false
end
end)

client.connect_signal("property::geometry", function(c)
local is_floating = c.floating or (c.first_tag and c.first_tag.layout == awful.layout.suit.floating)
if c.remember_geometry and is_floating and not c.fullscreen and not c.minimized then
	-- if client is almost maximized then set it to maximized.
	-- if client was maximized before allow to go back to normal view.
	cgeometry = c:geometry()
	sgeometry = c.screen.workarea
	c.remember_geometry.floating_geometry = cgeometry
	if not c.maximized_horizontal then
		diffWidth = sgeometry.width - cgeometry.width - c.border_width
		xpos = sgeometry.x - cgeometry.x
		if not c.remember_geometry.maximized_horizontal and diffWidth == 0 and xpos == 0 then
			c.remember_geometry.maximized_horizontal = true
			c.maximized_horizontal = true
		else
			c.remember_geometry.maximized_horizontal = false
		end
	end
	if not c.maximized_vertical then
		diffHeight = sgeometry.height - cgeometry.height - c.border_width
		ypos = sgeometry.y - cgeometry.y
		if not c.remember_geometry.maximized_vertical and diffHeight == 0 and ypos == 0 then
			c.remember_geometry.maximized_vertical = true
			c.maximized_vertical = true
		else
			c.remember_geometry.maximized_vertical = false
		end
	end
end
end)

client.connect_signal("property::fullscreen", function(c)
if c.floating and not c.fullscreen then
	c:geometry(c.remember_geometry.floating_geometry)
	if c.remember_geometry.maximized_manual then
		c.maximized_horizontal = true
		c.maximized_vertical = true
	end
end
end)
-- }}}
