-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

require("main.error-handling") --error handling

local vars = require("main.variables") --vars

--initializes theme
beautiful.init(gears.filesystem.get_xdg_config_home() ..
	"awesome/themes/" .. vars.theme .. "/theme.lua")

local mymainmenu = require("deco.menu") --shitty menu

-- does the thing for the menubar
menubar.utils.terminal = vars.terminal 

require("deco.screens")
require("deco.titlebar")

require("binding.bindings_mouse")
require("binding.bindings_key")

-- picom
awful.spawn("killall picom")
awful.spawn("picom")

-- {{{ Rules
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
	--[[{
		rule = {
			instance = 'sun-awt-X11-XFramePeer', 
			class = 'jetbrains-studio',
			name = 'Welcome to Android Studio'
		},
		properties = {
			titlebars_enabled = false,
			floating = true,
			focus = true,
			placement = awful.placement.centered
		}
	},
	{
		rule = {
			instance = 'sun-awt-X11-XWindowPeer', 
			class = 'jetbrains-studio',
			name = 'win0'
		},
		properties = {
			titlebars_enabled = false,
			floating = true,
			focus = true,
			border_width = 0,
			placement = awful.placement.centered
		}
	}]]
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
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


-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- TESTING
local interpolate = require("lib.interpolate")

local lesgo = interpolate.timed {
	duration = 1,
	--intro = 1,
	--outro = 1,
	rate = 3,
	--pos = 2,
	--easing = interpolate.quadratic,
	subscribed = function(pos, time, dx)
		print(tostring(pos))
	end
}

local popup = awful.popup {
	widget = {
		{
			text = "click me",
			widget = wibox.widget.textbox,
			buttons = awful.button({}, 1, function()
				if lesgo:is_started() then
					print("stopped")
					lesgo:abort()
				else
					print("\nstarted")
					lesgo:set(2)
				end
			end)
		},
		margins = 10,
		widget = wibox.container.margin
	},
	x = 10, y = 50,
	border_width = 0,
	shape = gears.shape.rounded_rect,
	visible = true
}
popup.visible = false

local tooltip = require("lib.tooltip")
local tt = tooltip.create_tooltip {}
tt:set_opacity(0.3)
