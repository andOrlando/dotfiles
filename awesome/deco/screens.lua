local wibox = require "wibox"
local gears = require "gears"
local awful = require "awful"
local beautiful = require "beautiful"
local naughty = require "naughty"
local dpi = require("beautiful.xresources").apply_dpi
local rubato = require "lib.rubato"
local color = require "lib.color"
local variables = require "main.variables"
rubato.set_def_rate(60)

local function round(x, p) 
	local power = math.pow(10, p or 0)
	return (x * power + 0.5 - (x * power + 0.5) % 1) / power 
end

--- useful color constants
local ia_rgb = color.color {hex=beautiful.gray, disable_hsl=true}	   --inactive color
local a_rgb = color.color {hex=beautiful.light_gray, disable_hsl=true} --active color
local u_rgb = color.color {hex=beautiful.bg_urgent, disable_hsl=true}  --urgent color
local s_rgb = color.color {hex=beautiful.light_blue, disable_hsl=true} --slidey color

-- Calculate the diff in colors for some stuff later on
local diff = {}
diff.r = ia_rgb.r - a_rgb.r
diff.g = ia_rgb.g - a_rgb.g
diff.b = ia_rgb.b - a_rgb.b

--- Draws a hollow arc (unused)
local function draw_arc(cr, height, ipos, fpos)
	--assert to constrain ipos and fpos
	assert(ipos <= 1 and ipos >= 0 and ipos <= 1 and fpos >= 0, 
		"position must be between 1 and 0")

	cr:set_line_width(dpi(2))
	cr:arc(height/2, height/2, dpi(3)*0.9, math.pi*2*(ipos or 0), math.pi*2*(fpos or 1))
	cr:stroke()
end

--- Makes a halo widget (unused)
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

--- Draws a circle
local function draw_circle(cr, height)
	cr:arc(height/2, height/2, 6, 0, math.pi * 2)
	cr:fill()
end

--- Draws the slidey thing
local function draw_slidey_thing(cr, height, xpos)
	cr:arc(xpos, height/2, 6, 0, math.pi*2)
	cr:fill()
end

--- Makes a circle widget
local function make_circle_widget(color)
	return wibox.widget {
		fit = function(self, context, width, height)
			return height, height
		end,
		draw = function(self, context, cr, width, height)
			cr:set_source_rgb(color.r / 255, color.g / 255, color.b / 255)
			draw_circle(cr, height)
		end,
		layout = wibox.widget.base.make_widget	
	}
end

--- Updates RGB for the taglist (to allow for hover)
local function update_rgb(w, rgb, diff)
	local r = (rgb.r + diff.ar + diff.ur) * diff.dim
	local g = (rgb.g + diff.ag + diff.ug) * diff.dim
	local b = (rgb.b + diff.ab + diff.ub) * diff.dim
	w.draw =
	function(self, context, cr, width, height)
		cr:set_source_rgb(r / 255, g / 255, b / 255)
		draw_circle(cr, height)
	end
	w:emit_signal("widget::redraw_needed")
end

--- Creates the taglist widgets.
local function create_taglist_widgets(s, slidey_thing)

	local l = {layout = wibox.layout.fixed.horizontal}

	for i, t in pairs(s.tags) do

		local w = make_circle_widget(ia_rgb)
		w.buttons = awful.button({}, 1,
			function() t:view_only() end)
		
		--difference in color
		local d = {ar=0, ag=0, ab=0, ur=0, ug=0, ub=0, dim=0}

		local active_timed = rubato.timed {
			intro = 0.075,
			duration = 0.2
		}

		local urgent_timed = rubato.timed {
			--difference in color
			intro = 0.075,
			duration = 0.2
		}

		local hover_timed = rubato.timed {
			intro = 0.075,
			duration = 0.2
		}

		active_timed:subscribe(function(pos)
			d.ar = -pos * diff.r
			d.ag = -pos * diff.g
			d.ab = -pos * diff.b
			update_rgb(w, ia_rgb, d)
		end)

		urgent_timed:subscribe(function(pos)
			d.ur = (u_rgb.r - a_rgb.r - d.ar) * pos
			d.ug = (u_rgb.g - a_rgb.g - d.ag) * pos
			d.ub = (u_rgb.b - a_rgb.b - d.ab) * pos
			update_rgb(w, ia_rgb, d)
		end)

		hover_timed:subscribe(function(pos)
			d.dim = 1 - 0.1 * pos
			update_rgb(w, ia_rgb, d)
		end)

		client.connect_signal("tagged", function()
			if not (#t:clients() == 0) then active_timed:set(1)
			else active_timed:set(0) end
		end)
		client.connect_signal("untagged", function()
			if not (#t:clients() == 0) then active_timed:set(1)
			else active_timed:set(0) end
		end)

		t:connect_signal("property::urgent", function()
			if awful.tag.getproperty(t, "urgent") then urgent_timed:set(1)
			else urgent_timed:set(0) end
		end)

		w:connect_signal("mouse::enter", function() 
			--look, I know this isn't by any means idiomatic, but it's either this or 
			--have a signal for every single one of the taglist widgets, which I really
			--don't want to do. So random variable put in tag it is.
			t.is_being_hovered = true
			hover_timed:set(1) 
			if s.selected_tag == t then slidey_thing:hover(1) end
		end)
		w:connect_signal("mouse::leave", function() 
			t.is_being_hovered = false
			hover_timed:set(0) 
			if s.selected_tag == t then slidey_thing:hover(0) end
		end)

		table.insert(l, w)
	end

	return l
	--[[{
		l,
		left = variables.taglist_padding_sides,
		right = variables.taglist_padding_sides,
		layout = wibox.container.margin
	}]]
end

--- Updates the position of the slidey thing
local function update_slidey_thing(w, dim, pos)
	w.draw =
	function(self, context, cr, width, height)
		cr:set_source_rgb(s_rgb.r * dim / 255, s_rgb.g * dim / 255, s_rgb.b * dim / 255)
		draw_slidey_thing(cr, height, 
			height/2 + (pos - 1) * height --[[+ variables.taglist_padding_sides]])
	end
	w:emit_signal("widget::redraw_needed")
end

--- Creates the slidey thing in the workspace switcher.
local function create_slidey_thing(s)
	local w = wibox.widget {
		fit = function(self, cocntext, width, height)
			return height, height
		end,

		draw = function(self, context, cr, width, height)
			cr:set_source_rgba(0.6, 0.6, 1, 0.3)
			draw_slidey_thing(cr, height, height/2 + variables.taglist_padding_sides)
		end,
		
		layout = wibox.widget.base.make_widget,
	}

	local index = 1

	-- Bouncy easing if I so please
	--[[local timed = rubato.timed {
		duration = 0.85,
		intro = 0.25,
		outro = 0.65,
		inter = 0.05,
		prop_intro = true,
		pos = index,
		easing = rubato.linear,
		easing_outro = rubato.bouncy
	}]]

	local timed = rubato.timed {
		duration = 0.3,
		intro = 0.1,
		pos = index,
		easing = rubato.linear,
	}

	local hover_timed = rubato.timed {
		intro = 0.075,
		duration = 0.2
	}

	local ti = {}
	for k,v in ipairs(s.tags) do ti[v] = k end

	local pos

	timed:subscribe(function(_pos)
		pos = _pos
		update_slidey_thing(w, dim, pos)
	end)

	hover_timed:subscribe(function(h_pos)
		dim = 1 - 0.2 * h_pos
		update_slidey_thing(w, dim, pos)
	end)

	s:connect_signal("tag::history::update", function() 
		if ti[s.selected_tag] == w.index then return end

		timed:set(ti[s.selected_tag])
		index = ti[s.selected_tag]

		hover_timed:set(s.selected_tag.is_being_hovered and 1 or 0)
	end)

	function w:hover(value) hover_timed:set(value) end

	--[[w:connect_signal("mouse::enter", function() hover_timed:set(1) end)
	w:connect_signal("mouse::leave", function() hover_timed:set(0) end)]]

	return w
end

local full = color.color {r=60, g=131, b=242}
local empty = color.color {r=89, g=0, b=175}

--- Create the battery widget
local function create_battery_widget()
	
	local w = wibox.widget {
		align = "center",
		widget = wibox.widget.textbox
	}

	local w = wibox.widget {
		widget = wibox.widget.imagebox
	}

	local a = wibox.widget {
		w,
		max_value = 100,
		value = 100,
		start_angle = 1.5 * math.pi,
		border_width = 0,
		rounded_edge = true,
		widget = wibox.container.arcchart
	}

	awesome.connect_signal("signal::battery", function(percentage, state)

		-- Do charging state
		--local markup = "<span font='11'>"

		-- 4 is charging at full, 2 is not charging, 1 is charging and not at full
		if state == 4.0 or state == 1.0 then w.image = beautiful.battery_charging 

		elseif state == 2.0 then
			if percentage >= 95 then w.image = beautiful.battery_full
			elseif percentage >= 85 then w.image = beautiful.battery_90
			elseif percentage >= 75 then w.image = beautiful.battery_80
			elseif percentage >= 65 then w.image = beautiful.battery_70
			elseif percentage >= 55 then w.image = beautiful.battery_60
			elseif percentage >= 45 then w.image = beautiful.battery_50
			elseif percentage >= 35 then w.image = beautiful.battery_40
			elseif percentage >= 25 then w.image = beautiful.battery_30
			elseif percentage >= 15 then w.image = beautiful.battery_20
			elseif percentage >= 5 then w.image = beautiful.battery_10 
			else w.image = beautiful.battery_low end

		else  w.image = beautiful.battery_unknown end
		
		--[[markup = markup .. "</span>"]]
		--[[w.markup = markup]]
			
		-- Set percentage and color
		a.value = percentage
		a.colors = {color.rgb_to_hex {
			empty.r + (full.r - empty.r) * percentage / 100,
			empty.g + (full.g - empty.g) * percentage / 100,
			empty.b + (full.b - empty.b) * percentage / 100,
			true
		}}

		a:emit_signal("widget::redraw_needed")
	end)


	return a
end

local green = color.color {r=97, g=232, b=87, disable_hsl=true}
local red = color.color {r=232, g=87, b=87, disable_hsl=true}

local last_color = color.color {r=232, g=87, b=87}
local next_color = color.color {r=232, g=87, b=87}
last_color.h = last_color.h - 40

local function create_volume_widget()
	--[[local w = wibox.widget {
		align = "center",
		widget = wibox.widget.textbox
	}]]

	local w = wibox.widget {
		widget = wibox.widget.imagebox
	}

	local a = wibox.widget {
		w,
		min_value = 0,
		max_value = 100,
		start_angle = 1.43 * math.pi,
		rounded_edge = true,
		widget = wibox.container.arcchart
	}

	local prev_pos = 0

	local arc_timed = rubato.timed {
		duration = 0.2,
		intro = 0.3,
		prop_intro = true
	}

	arc_timed:subscribe(function(pos)
		pos = round(pos, 5) --rounding because float math sucks

		local value

		--If it's zero just display as blank and quit
		if pos == 0 then 
			a.colors = {"#ffffff00"} 
			return 
		end

		if pos % 100 == 0 then value = 100
		else value = pos % 100 end
		
		a.value = 7.5 + value * 0.925

		-- For stuf above 200 just increase hue
		if prev_pos > 200 or pos > 200 then 
			local closest_hundred = round(pos, -2)
			if pos > closest_hundred and prev_pos <= closest_hundred then
				last_color.h = last_color.h + 40
				next_color.h = next_color.h + 40
			elseif pos <= closest_hundred and prev_pos > closest_hundred then
				last_color.h = last_color.h - 40
				next_color.h = next_color.h - 40
			end

			-- Do cool transition
			a.bg = last_color.hex
			a.colors = {color.rgb_to_hex{
				last_color.r + (next_color.r - last_color.r) * value / 100,
				last_color.g + (next_color.g - last_color.g) * value / 100,
				last_color.b + (next_color.b - last_color.b) * value / 100,
				true
			}}
		end

		if 200 > pos and pos > 100 then
			a.bg = beautiful.light_gray
			a.colors = {color.rgb_to_hex{
				green.r + (red.r - green.r) * value / 100,
				green.g + (red.g - green.g) * value / 100,
				green.b + (red.b - green.b) * value / 100,
				true
			}}
		elseif pos <= 100 then
			a.bg = nil
			a.colors = {beautiful.light_gray}
		end

		prev_pos = pos

	end)

	awesome.connect_signal("signal::volume", function(percentage, muted)

		arc_timed:set(percentage)

		--local markup = "<span font='17'>"

		if muted then w.image = beautiful.volume_mute
		elseif percentage >= 75 then w.image = beautiful.volume_high
		elseif percentage >= 25 then w.image = beautiful.volume_mid
		else w.image = beautiful.volume_low 
		end

		--markup = markup .. "</span>"
		--w.markup = markup
	end)

	return a
end

local hour_color = color.color {r=50, g=0, b=100, disable_hsl=true}
local min_color = color.color {r=89, g=0, b=175, disable_hsl=true}
local sec_color = color.color {r=60, g=131, b=242, disable_hsl=true}

local function create_cool_clock_widget()
	local time = os.time()
	local sec, min, hour = os.date("%S", time), os.date("%M", time), os.date("%H") % 12

	local a1 = wibox.widget {
		min_value = 0,
		max_value = 100,
		start_angle = 1.42 * math.pi,
		rounded_edge = true,
		bg = "#ffffff00",
		colors = {sec_color.hex},
		widget = wibox.container.arcchart
	}

	local a2 = wibox.widget {
		a1,
		min_value = 0,
		max_value = 100,
		start_angle = 1.42 * math.pi,
		rounded_edge = true,
		bg = "#ffffff00",
		colors = {min_color.hex},
		widget = wibox.container.arcchart
	}

	local a3 = wibox.widget {
		a2,
		min_value = 0,
		max_value = 100,
		start_angle = 1.42 * math.pi,
		rounded_edge = true,
		bg = "#ffffff10",
		colors = {hour_color.hex},
		widget = wibox.container.arcchart
	}

	local a1_timed = rubato.timed {
		duration = 2, intro = 0.3, prop_intro = true,
		subscribed = function(pos) a1.value = 15+pos/59*100*0.85 end
	}
	local a2_timed = rubato.timed {
		duration = 4, intro = 0.3, prop_intro = true,
		subscribed = function(pos) a2.value = 11.25+pos/59*100*0.8975 end
	}
	local a3_timed = rubato.timed {
		duration = 6, intro = 0.4, prop_intro = true,
		subscribed = function(pos) a3.value = 7.5+pos/11*100*0.925 end
	}

	local timer = gears.timer {timeout = 1}
	timer:connect_signal("timeout", function()
		-- Do time stuff
		sec = sec + 1
		if sec == 60 then
			sec = 0
			min = min + 1
			if min == 60 then
				min = 0
				hour = (hour + 1) % 12
			end
		end

		-- Update circles
		a1_timed:set(sec)
		a2_timed:set(min)
		a3_timed:set(hour)
	end)

	timer:start()

	return a3
end

local function create_tasklist_widget(s) --TODO
	local w = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		layout = {
			--[[spacing_widget = {
				{
					forced_width  = 5,
					forced_height = 24,
					thickness     = 1,
					color         = '#777777',
					widget        = wibox.widget.separator
				},
				valign = 'center',
				halign = 'center',
				widget = wibox.container.place,
			},
			spacing = 1,]]
			layout  = wibox.layout.fixed.vertical
		},
		-- Notice that there is *NO* wibox.wibox prefix, it is a template,
		-- not a widget instance.
		widget_template = {
			--[[{
				wibox.widget.base.make_widget(),
				forced_height = 5,
				id            = 'background_role',
				widget        = wibox.container.background,
			},]]
			{
				{
					id     = 'clienticon',
					widget = awful.widget.clienticon,
				},
				margins = 6,
				widget  = wibox.container.margin
			},
			--nil,
			create_callback = function(self, c, index, objects) --luacheck: no unused args
				self:get_children_by_id('clienticon')[1].client = c
			end,
			layout = wibox.layout.align.vertical,
		},
	}
	
	return w
end


local function create_top_navbar(s)

	local above_taglist = {layout = wibox.layout.fixed.horizontal}

	--make clickable overlay
	--TODO: make slidey thing work with these
	for _, t in pairs(s.tags) do
		table.insert(above_taglist, wibox.widget {
			fit = function(_, _, _, height) return height end,
			buttons = awful.button({}, 1, function() t:view_only() end),
			widget = wibox.widget.base.make_widget
		})
	end

	--- Create the slidey thing beforehand as to pass it into the taglist widgets
	local slidey_thing = create_slidey_thing(s)

	-- create wibar
    --[[s.top_navbar = awful.wibar {
		position = "top", 
		screen = s, 
		height = variables.navbar_height
	}]]

	s.top_navbar = awful.popup {
		widget = {	{	{	{	{	create_taglist_widgets(s, slidey_thing),
							slidey_thing,
							above_taglist,
							layout = wibox.layout.stack
						},
						left = variables.taglist_padding_sides,
						right = variables.taglist_padding_sides,
						layout = wibox.container.margin
					},
					bg = beautiful.bg_normal_1,
					shape = gears.shape.rounded_bar,
					shape_clip = true,
					layout = wibox.container.background
				},
				margins = dpi(6),
				layout = wibox.container.margin
			},

			--- Middle (empty for now)
			wibox.widget {},

			--- Right
			{	{	create_cool_clock_widget(),
					create_battery_widget(),
					create_volume_widget(),
					spacing = dpi(6),
					layout = wibox.layout.fixed.horizontal
				},
				margins = dpi(4),
				layout = wibox.container.margin
			},
			layout = wibox.layout.align.horizontal,
		},
		screen = s,
		minimum_height = variables.navbar_height,
		maximum_height = variables.navbar_height,
		minimum_width = s.geometry.width,
		maximum_width = s.geometry.width,
		bg = beautiful.bg_normal

	}

	s.top_navbar:struts {
		bottom = 0, left = 0, right = 0,
		top = 40
	}



	naughty.notify {text=s.geometry.width.." "}

	--[[s.top_navbar = awful.popup {
		widget = {	{	{	{	{	create_taglist_widgets(s, slidey_thing),
							slidey_thing,
							above_taglist,
							layout = wibox.layout.stack
						},
						left = variables.taglist_padding_sides,
						right = variables.taglist_padding_sides,
						layout = wibox.container.margin
					},
					bg = beautiful.bg_normal_1,
					shape = gears.shape.rounded_bar,
					shape_clip = true,
					layout = wibox.container.background
				},
				margins = dpi(6),
				layout = wibox.container.margin
			},

			--- Middle (empty for now)
			wibox.widget {},

			--- Right
			{	{	create_cool_clock_widget(),
					create_battery_widget(),
					create_volume_widget(),
					spacing = dpi(6),
					layout = wibox.layout.fixed.horizontal
				},
				margins = dpi(4),
				layout = wibox.container.margin
			},
			layout = wibox.layout.align.horizontal,
		},
		screen = s,
		height = variables.navbar_height,
		width = s.geometry.width
	}]]

	--wibar setup
	--[[s.top_navbar:setup {
		--- Left
		{	{	{	{	create_taglist_widgets(s, slidey_thing),
						slidey_thing,
						above_taglist,
						layout = wibox.layout.stack
					},
					left = variables.taglist_padding_sides,
					right = variables.taglist_padding_sides,
					layout = wibox.container.margin
				},
				bg = beautiful.bg_normal_1,
				shape = gears.shape.rounded_bar,
				shape_clip = true,
				layout = wibox.container.background
			},
			margins = dpi(6),
			layout = wibox.container.margin
		},

		--- Middle (empty for now)
		wibox.widget {},

		--- Right
		{	{	create_cool_clock_widget(),
				create_battery_widget(),
				create_volume_widget(),
				spacing = dpi(6),
				layout = wibox.layout.fixed.horizontal
			},
			margins = dpi(4),
			layout = wibox.container.margin
		},
		layout = wibox.layout.align.horizontal,
	}]]

	--[[for k, v in pairs(s.top_navbar:struts()) do
		naughty.notify {text=k.." "..v}
	end

	s.top_navbar:struts {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0
	}]]
	
end

local function create_left_navbar(s)
	s.left_navbar = awful.wibar {
		position = "left",
		screen = s,
		bg = beautiful.bg_normal.."64",
		width = dpi(38),
		ontop = true,
	}

	s.left_navbar:setup {
		{	create_tasklist_widget(s),
			layout = wibox.layout.fixed.vertical
		},
		layout = wibox.layout.align.vertical
	}
end

-- Sets wallpaper
local function set_wallpaper(s) 
	local wallpaper = beautiful.wallpaper
	if type(wallpaper) == "function" then
		gears.wallpaper.maximized(wallpaper(s), s, true)
	elseif not (wallpaper == nil) then
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)

	--create tags
	for i = 1, 9, 1 do
		awful.tag.add(tostring(i), {
			layout = awful.layout.suit.tile,
			gap = dpi(15),
			gap_single_client = true,
		})
	end

	tag = s.tags[1]:view_only()

	create_left_navbar(s)
	create_top_navbar(s)
	set_wallpaper(s)
end)


