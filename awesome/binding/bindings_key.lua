local gears = require("gears")
local awful = require("awful")
local vars = require("main.variables")
local mymainmenu = require("deco.menu")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local mk = vars.modkey

globalkeys = gears.table.join(
	--- Utils
	awful.key({mk}, "s", hotkeys_popup.show_help,
		{description="Show Help", group="Utils"}),
	awful.key({}, "Print", 
		function() awful.spawn("shutter -s") end,
		{description="Screenshot to Clipboard", group="Utils"}),
	awful.key({mk}, "Return", function() awful.spawn(vars.terminal) end,
		{description="Open Terminal", group="Utils"}),
	awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end,
		{description="Increase Volume", group="Utils"}),
	awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end,
		{description="Decrease Volume", group="Utils"}),
	awful.key({}, "XF86AudioMute", function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end,
		{description="Mute Volume", group="Utils"}),



	--- State
	awful.key({mk, "Control"}, "r", awesome.restart,
		{description="Restart Awesome", group="State"}),
	awful.key({mk, "Shift"}, "e", awesome.quit,
		{description="Quit Awesome", group="State"}),

	--- Window Management
	awful.key({mk}, "j", function() awful.client.focus.byidx(1) end),
	awful.key({mk}, "k", function() awful.client.focus.byidx(-1) end),
	awful.key({mk, "Shift"}, "j", function() awful.client.swap.byidx(1) end),
	awful.key({mk, "Shift"}, "k", function() awful.client.swap.byidx(-1) end),
	awful.key({mk}, "u", awful.client.urgent.jumpto,
		{description="Jump to Urgent Client", group="Windows"}),
	awful.key({mk}, "Escape", awful.tag.history.restore,
		{description="Restore last Tag", group="Windows"}),
	awful.key({mk, "Shift"}, "j", function() awful.client.swap.byidx(1) end,
		{description="Increment Focus", group="Windows"}),
	awful.key({mk, "Shift"}, "k", function() awful.client.swap.byidx(-1) end,
		{description="Decrement Focus", group="Windows"})

	--- Bad ones that are useful to keep around
	--awful.key({mk}, "Left", awful.tag.viewprev)
	--awful.key({mk}, "Right", awful.tag.viewnext)
	--awful.key({mk}, "w", function() mymainmenu:show() end)
	--awful.key({mk, "Control"}, "j", function() awful.screen.focus_relative(1) end)
	--awful.key({mk, "Control"}, "k", function() awful.screen.focus_relative(-1) end)
	--awful.key({mk}, "Tab", 
	--	function()
	--		awful.client.focus.history.previous()
	--		if client.focus then client.focus:raise() end
	--	end end,) --Goes back one client

)

-- {{{ Key bindings
globalkeys = gears.table.join(globalkeys,
	
	awful.key({ vars.modkey, }, "l",	 function () awful.tag.incmwfact( 0.05)		  end,
			  {description = "increase master width factor", group = "layout"}),
	awful.key({ vars.modkey, }, "h",	 function () awful.tag.incmwfact(-0.05)		  end,
			  {description = "decrease master width factor", group = "layout"}),
	awful.key({ vars.modkey, "Shift"   }, "h",	 function () awful.tag.incnmaster( 1, nil, true) end,
			  {description = "increase the number of master clients", group = "layout"}),
	awful.key({ vars.modkey, "Shift"   }, "l",	 function () awful.tag.incnmaster(-1, nil, true) end,
			  {description = "decrease the number of master clients", group = "layout"}),
	awful.key({ vars.modkey, "Control" }, "h",	 function () awful.tag.incncol( 1, nil, true)	end,
			  {description = "increase the number of columns", group = "layout"}),
	awful.key({ vars.modkey, "Control" }, "l",	 function () awful.tag.incncol(-1, nil, true)	end,
			  {description = "decrease the number of columns", group = "layout"}),
	--awful.key({ vars.modkey, }, "space", function () awful.layout.inc( 1)				end,
	--		  {description = "select next", group = "layout"}),
	--awful.key({ vars.modkey, "Shift"   }, "space", function () awful.layout.inc(-1)				end,
	--		  {description = "select previous", group = "layout"}),

	awful.key({ vars.modkey, "Control" }, "n",
			  function ()
				  local c = awful.client.restore()
				  -- Focus restored client
				  if c then
					c:emit_signal(
						"request::activate", "key.unminimize", {raise = true}
					)
				  end
			  end,
			  {description = "restore minimized", group = "client"}),

	--the old thing was awful.screen.focused().mypromptbox:run()
	awful.key ({ vars.modkey }, "d", function () os.execute("rofi -modi drun,run -show drun") end,
		{description = "execute rofi", group = "launcher"}),

	awful.key({ vars.modkey }, "x",
			  function ()
				  awful.prompt.run {
					prompt	   = "Run Lua code: ",
					textbox	  = awful.screen.focused().mypromptbox.widget,
					exe_callback = awful.util.eval,
					history_path = awful.util.get_cache_dir() .. "/history_eval"
		}
			  end,
			  {description = "lua execute prompt", group = "awesome"}),
	-- Menubar
	awful.key({ vars.modkey }, "p", function() menubar.show() end,
			  {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
	awful.key({ vars.modkey, }, "f",
		function (c)
			c.maximized = not c.maximized
			c:raise()
		end,
		{description = "toggle fullscreen", group = "client"}),
	awful.key({ vars.modkey, "Shift"   }, "q",	  function (c) c:kill()						 end,
			  {description = "close", group = "client"}),
	awful.key({ vars.modkey }, "space",  awful.client.floating.toggle					 ,
			  {description = "toggle floating", group = "client"}),
	awful.key({ vars.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
			  {description = "move to master", group = "client"}),
	awful.key({ vars.modkey, }, "o",	  function (c) c:move_to_screen()			   end,
			  {description = "move to screen", group = "client"}),
	awful.key({ vars.modkey, }, "t",	  function (c) c.ontop = not c.ontop			end,
			  {description = "toggle keep on top", group = "client"}),
	awful.key({ vars.modkey, }, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end ,
		{description = "minimize", group = "client"}),
	awful.key({ vars.modkey, }, "m",
		function (c)
			c.maximized = not c.maximized
			c:raise()
		end ,
		{description = "(un)maximize", group = "client"}),
	awful.key({ vars.modkey, "Control" }, "m",
		function (c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end ,
		{description = "(un)maximize vertically", group = "client"}),
	awful.key({ vars.modkey, "Shift"   }, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end ,
		{description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ vars.modkey }, "#" .. i + 9,
				  function ()
						local screen = awful.screen.focused()
						local tag = screen.tags[i]
						if tag then
						   tag:view_only()
						end
				  end,
				  {description = "view tag #"..i, group = "tag"}),
		-- Toggle tag display.
		awful.key({ vars.modkey, "Control" }, "#" .. i + 9,
				  function ()
					  local screen = awful.screen.focused()
					  local tag = screen.tags[i]
					  if tag then
						 awful.tag.viewtoggle(tag)
					  end
				  end,
				  {description = "toggle tag #" .. i, group = "tag"}),
		-- Move client to tag.
		awful.key({ vars.modkey, "Shift" }, "#" .. i + 9,
				  function ()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:move_to_tag(tag)
						  end
					 end
				  end,
				  {description = "move focused client to tag #"..i, group = "tag"}),
		-- Toggle tag on focused client.
		awful.key({ vars.modkey, "Control", "Shift" }, "#" .. i + 9,
				  function ()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:toggle_tag(tag)
						  end
					  end
				  end,
				  {description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

clientbuttons = gears.table.join(
	awful.button({ }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
	end),
	awful.button({ vars.modkey }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.move(c)
	end),
	awful.button({ vars.modkey }, 3, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}
