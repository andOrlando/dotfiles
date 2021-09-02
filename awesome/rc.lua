-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")


-- Important libraries
local awful = require "awful"
local beautiful = require "beautiful"
local menubar = require "menubar" --TODO: remove
local vars = require "main.variables"

-- Reloaded config message
awful.spawn "notify-send 'reloaded config' nice"

-- Set up awful stuff
require "awful.hotkeys_popup"
require "awful.hotkeys_popup.keys"
require "awful.autofocus"

-- Set up error handling
require "main.error-handling"

-- Set up a bunch of signals (thanks JavaCafe01)
require "lib.battery"
require "lib.volume"
require("lib.playerctl").enable { backend = "playerctl_lib" }
require "lib.cpu"
require "lib.ram"
require "lib.disk"

-- Register some xproperties
awesome.register_xproperty("WM_CLASS", "string")

-- Initializes theme
beautiful.init(require("gears").filesystem.get_xdg_config_home() ..
	"awesome/themes/" .. vars.theme .. "/theme.lua")

-- Shitty menu TODO: remove
local mymainmenu = require("deco.menu")

-- Does the thing for the menubar (still remove)
menubar.utils.terminal = vars.terminal

-- Sets up deco stuff
require "deco.screens"
require "deco.titlebar"

-- Sets up binding stuff
require "binding.bindings_mouse"
require "binding.bindings_key"

-- picom
awful.spawn.once "picom"


awful.rules.rules = {
	--normal
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
		},
	},

	--placement
	{
		rule = {},
		properties = { placement = awful.placement.no_overlap+awful.placement.no_offscreen },
		except_any = {
			class = { "jetbrains-studio" }
		}
	},

	--titlebars
	{
		rule_any = {
			type = {
				"normal",
				"dialog"
			}
		},
		properties = { titlebars_enabled = true },
	},


    -- Floating clients.
    {
		rule_any = {
			instance = {
				"DTA",  -- Firefox addon DownThemAll.
				"pinentry",
			},
			class = {
				"Blueman-manager",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"sun-awt-X11-XWindowPeer"
			},

			role = {
				"pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = { floating = true },
	},

	-- Android Studio
	--[[{
		rule = {
			instance = 'sun-awt-X11-XFramePeer',
			class = 'jetbrains-studio'
		},
		properties = {
			--titlebars_enabled = false,
			floating = false
		}
	},]]
	{
		rule = {
			instance = 'sun-awt-X11-XWindowPeer',
			class = 'jetbrains-studio',
			type = 'dialog'
		},
		properties = {
			titlebars_enabled = false,
			border_width = 0,
			floating = true,
			focus = true,
			placement = nil
		}
	},
	{
		rule = {
			instance = 'sun-awt-X11-XFramePeer',
			class = 'jetbrains-studio',
			name = 'Android Virtual Device Manager'
		},
		rule_any = {
			name = {
				'Android Virtual Device Manager',
				'Welcome to Android Studio',
				'win0'
			}
		},
		properties = {
			titlebars_enabled = true,
			floating = true,
			focus = true,
			placement = awful.placement.centered
		}
	},
}


client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)


client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

--[[
local timed = require("lib.rubato").timed {
	intro = 0.2,
	duration = 0.25,
	prop_intro = true
}

local naughty = require 'naughty'
timed:subscribe(function(pos)
	naughty.notify {text=tostring(pos)}
	print(pos)
end)

timed.target = 1
]]
