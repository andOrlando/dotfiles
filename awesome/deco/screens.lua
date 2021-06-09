local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local awestore = require("awestore")
local interpolator= require("lib.interpolate")


local navbar_height = dpi(20)

-- Sets wallpaper
-- @param screen just the screen
local function set_wallpaper(s) 
	local wallpaper = beautiful.wallpaper
	--naughty.notify({text=tostring(wallpaper)})
	if type(wallpaper) == "function" then
		gears.wallpaper.maximized(wallpaper(s), s, true)
	elseif not (wallpaper == nil) then
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

screen.connect_signal("property::geometry", set_wallpaper)

--- Draws hollow arc.
-- @param cr cairo
-- @param height height
-- @param[opt] ipos the initial degrees in radians to draw the arc [0, 1]
-- @param[opt] fpos the final degrees in radians to draw the arc [0, 1]
local function draw_arc(cr, height, ipos, fpos)
	--assert to constrain ipos and fpos
	assert(ipos <= 1 and ipos >= 0 and ipos <= 1 and fpos >= 0, 
		"position must be between 1 and 0")

	cr:set_line_width(dpi(2))
	cr:arc(height/2, height/2, dpi(3)*0.9, math.pi*2*(ipos or 0), math.pi*2*(fpos or 1))
	cr:stroke()
end

--- Draws the slidey thing.
-- @param cr cairo
-- @param height height
-- @param xpos the position to draw it at, initailly the index
local function draw_slidey_thing(cr, height, xpos)
	cr:arc(xpos, height/2, dpi(13), 0, math.pi*2)
	cr:fill()
end

--- Makes a hollow circle widget.
-- @param r the red value [0, 1]
-- @param g the green value [0, 1]
-- @param b the blue value [0, 1]
-- @param[opt] a the alpha value [0, 1]
-- @param[pot] init the initial percentage of halo circled
local function make_halo_widget(r, g, b, a, init)
	--r, g, b, a are colors from [0, 1]
	--init is initial position [0, 1] for arc
	return wibox.widget {
		fit = function(self, context, width, height)
			return height, height
		end,
		draw = function(self, context, cr, width, height)
			cr:set_source_rgba(r, g, b, (a or 1))
			draw_arc(cr, height, 0, (init or 1))
		end,
		layout = wibox.widget.base.make_widget	
	}
end

--- Makes a hollow circle widget.
-- @param args the table of arguments
--    @field colors list of colors in order: r, g, b and a
--   _@field colors_sub same order as colors but the colors for the underlying halo
--   _@field init the initial percentage filled of colors
--[[local function make_halo_widget(args)
	setmetatable(args, {__index = {
		colors = {1, 1, 1, 1}
		colors_sub = {0.5, 0.5, 0.5, 0.5}
		init = 1
	}})
	return wibox.widget {
		fit = function(_, _, _, height)
			return height, height
		end,
		draw = function(_, _, cr, _, height)
			cr:set_source_rgba(
				args.colors[0], 
				args.colors[1], 
				args.colors[2], 
				args.colors[3])
			draw_arc(cr, height, 0, colors.init)
			cr:set_source_rgba(
				args.colors_sub[0],
				args.colors_sub[1],
				args.colors_sub[2],
				args.colors_sub[3])
			draw_arc(cr, height, colors.init, 1-colors.init)
		end
	}
end]]

--- Creates the taglist widgets.
-- @param s screen
-- @return layout that contains the taglist widgets
-- @see create_slidey_thing
-- @see create_navbar
local function create_taglist_widgets(s)

	local l = {layout = wibox.layout.fixed.horizontal}

	for _, t in pairs(s.tags) do
		
		local a = make_halo_widget(0.5, 0.5, 0.5, 0.5)
		a.buttons = awful.button({}, 1, 
			function() t:view_only() end)
	
		local b = make_halo_widget(0.75, 0.75, 0.80)

		local active_tween = awestore.tweened(0, {
			duration = 100,
			easing = awestore.easing.linear
		})

		active_tween:subscribe(function(pos)
			b.draw = 
			function(self, context, cr, width, height)
				cr:set_source_rgb(0.75, 0.75, 0.80)
				draw_arc(cr, height, 0, pos)
			end
			b:emit_signal("widget::redraw_needed")
		end)
		
		client.connect_signal("tagged", function()
			if not (#t:clients() == 0) then active_tween:set(1)
			else active_tween:set(0) end
		end)
		client.connect_signal("untagged", function()
			if not (#t:clients() == 0) then active_tween:set(1)
			else active_tween:set(0) end

		end)
		

		local c = make_halo_widget(56/255, 146/255, 1)

		local urgent_tween = awestore.tweened(0, {
			duration = 250,
			easing = awestore.easing.linear
		})

		urgent_tween:subscribe(function(pos)
			c.draw = 
			function(self, context, cr, width, height)
				cr:set_source_rgb(56/255, 146/255, 1)
				draw_arc(cr, height, 0, pos)
			end		
			c:emit_signal("widget::redraw_needed")
		end)

		t:connect_signal("property::urgent", function()
			if awful.tag.getproperty(t, "urgent") then urgent_tween:set(1)
			else urgent_tween:set(0) end
		end)
		
		table.insert(l, {
			a, b, c,
			buttons = awful.button({}, 1, function()
				t:view_only()
			end),
			layout = wibox.layout.stack
		})
	end

	return l
end


--- Creates the slidey thing in the workspace switcher.
-- @param s screen
-- @return slidey thing
-- @see create_taglist_widgets
-- @see create_navbar
local function create_slidey_thing(s)
	local w = wibox.widget {
		fit = function(self, cocntext, width, height)
			return height, height
		end,

		draw = function(self, context, cr, width, height)
			cr:set_source_rgba(0.6, 0.6, 1, 0.3)
			draw_slidey_thing(cr, height, height/2)
		end,
		
		layout = wibox.widget.base.make_widget,
	}

	w.index = 1

	--w.slide_intp = interpolator({ slope = 0.3, pos = w.index })
	w.slide_timed = interpolator.timed {
		duration = 0.3,
		intro = 0.10,
		--rate = 120,
		easing = interpolator.linear,
		pos = w.index
	}

	local ti = {}
	for k,v in ipairs(s.tags) do ti[v] = k end

	w.slide_timed:subscribe(function(pos, _, dx)
		w.draw =
		function(self, context, cr, width, height)
			cr:set_source_rgba(0.6, 0.6, 1, 0.3)
			draw_slidey_thing(cr, height, height/2 + (pos - 1) * height)
		end
		--print(tostring(pos))
		w:emit_signal("widget::redraw_needed")
	end)

	s:connect_signal("tag::history::update", function() 
		if ti[s.selected_tag] == w.index then return end

		w.slide_timed:set(ti[s.selected_tag])
		w.index = ti[s.selected_tag]
	end)

	return w
end

local function create_battery_widget() --TODO
	
end

local function create_volume_widget() --TODO

end

local function create_minimized_widget(s) --TODO
	local l = wibox.widget { layout = wibox.layout.fixed.horizontal }

	local w = make_halo_widget(1, 1, 1)
	--[[wibox.widget {
		buttons = awful.button({}, 1, function()
			naughty.notify({text=tostring(l)})
			table.insert(l, {
				text = "hi",
				widget = wibox.widget.textbox
			})
			--l:emit_signal ("widget::redraw_needed")
		end),

		text = "this is the widget",
		widget = wibox.widget.textbox
	}]]
	
	table.insert(l, w)

	return l
end


local function create_navbar(s)

	-- create wibar
    s.top_navbar = awful.wibar({ 
		position = "top", 
		screen = s, 
		height = navbar_height
	})

	--wibar setup
	s.top_navbar:setup {
		{
			create_slidey_thing(s),
			create_taglist_widgets(s),
			layout = wibox.layout.stack
		},
		create_minimized_widget(s),
		wibox.widget.textclock("%H:%M"),
		layout = wibox.layout.align.horizontal,
	}
	
end


awful.screen.connect_for_each_screen(function(s)

    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" },
		s, awful.layout.layouts[1])

	create_navbar(s)
	set_wallpaper(s)
end)


