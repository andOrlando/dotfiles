local awful = require "awful" 
local dpi = require("beautiful.xresources").apply_dpi

-- Variable Definitions: {{{
local _M = {
	theme = "suncolors",
	terminal = "kitty",
	editor = os.getenv("EDITOR") or "nvim",
	modkey = "Mod4",
	navbar_height = dpi(28),
	taglist_padding_sides = dpi(8)
}
_M.editor_cmd = _M.terminal .. " -e " .. _M.editor
-- }}}
-- Layout Format {{{
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}
return _M
