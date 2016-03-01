awesome-remember-geometry
=========================

A [awesome wm](https://github.com/awesomeWM/awesome) plugin that stores client geometry information when switching between floating and tiling, maximized and fullscreen and other scenarios.

## Installation ##

Clone the repo into your `$XDG_CONFIG_HOME/awesome` directory and add the dependency to your `rc.lua`.

```Lua
require("awesome-remember-geometry")
```

## Configuration ##

If you would like to map a key to maximize a client you should emit the new `maximize` signal on it

```Lua
awful.key({ modkey, }, "Up", function (c)
	c:emit_signal("maximize")
end)
```

## License ##

See [LICENSE](LICENSE).
