local awful = require("awful")
local vars = require("main.variables")
local beautiful = require("beautiful")

-- {{{ Menu
-- Create a launcher widget and a main menu
menuitems = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", vars.terminal .. " -e man awesome" },
   { "edit config", vars.editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mainmenu = awful.menu(
	{ items = { 
			{ "awesome", menuitems, beautiful.awesome_icon },
			{ "open terminal", vars.terminal }}
	})

return mainmenu
