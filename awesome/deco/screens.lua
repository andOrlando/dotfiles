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

--- useful color constants TODO: put this in variables
local ia_rgb = color.color {hex=beautiful.gray}		 --inactive color
local a_rgb = color.color {hex=beautiful.light_gray} --active color
local u_rgb = color.color {hex=beautiful.bg_urgent}	 --urgent color
local s_rgb = color.color {hex=beautiful.light_blue} --slidey color

local diff = {}
diff.r = ia_rgb.r - a_rgb.r
diff.g = ia_rgb.g - a_rgb.g
diff.b = ia_rgb.b - a_rgb.b

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

--- Draws a hollow arc
-- ipos and fpos are optional
local function draw_arc(cr, height, ipos, fpos)
	--assert to constrain ipos and fpos
	assert(ipos <= 1 and ipos >= 0 and ipos <= 1 and fpos >= 0, 
		"position must be between 1 and 0")

	cr:set_line_width(dpi(2))
	cr:arc(height/2, height/2, dpi(3)*0.9, math.pi*2*(ipos or 0), math.pi*2*(fpos or 1))
	cr:stroke()
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

--- Makes a halo widget (old)
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
-- @see create_slidey_thing
-- @see create_navbar
local function create_taglist_widgets(s)

	local l = {layout = wibox.layout.fixed.horizontal}

	for _, t in pairs(s.tags) do

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

		w:connect_signal("mouse::enter", function() hover_timed:set(1) end)
		w:connect_signal("mouse::leave", function() hover_timed:set(0) end)

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
-- @see create_taglist_widgets
-- @see create_navbar
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
	end)

	w:connect_signal("mouse::enter", function() hover_timed:set(1) end)
	w:connect_signal("mouse::leave", function() hover_timed:set(0) end)

	return w
end

local green = color.color {r=97, g=232, b=87}
local red = color.color {r=232, g=87, b=87}


--- Create the battery widget
local function create_battery_widget()
	
	local w = wibox.widget {
		markup = "<span font='9'></span>",
		align = "center",
		widget = wibox.widget.textbox
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

	local l = wibox.widget {
		a,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin
	}

	awesome.connect_signal("signal::battery", function(percentage, state)

		-- Do charging state
		local markup = "<span font='9'>"

		-- 4 is charging at full, 2 is not charging, 1 is charging and not at full
		if state == 4.0 or state == 1.0 then markup = markup .. ""

		elseif state == 2.0 then
			if percentage >= 95 then markup = markup .. ""
			elseif percentage >= 85 then markup = markup .. ""
			elseif percentage >= 75 then markup = markup .. ""
			elseif percentage >= 65 then markup = markup .. ""
			elseif percentage >= 55 then markup = markup .. ""
			elseif percentage >= 45 then markup = markup .. ""
			elseif percentage >= 35 then markup = markup .. ""
			elseif percentage >= 25 then markup = markup .. ""
			elseif percentage >= 15 then markup = markup .. ""
			elseif percentage >= 5 then markup = markup .. ""
			else markup = markup .. "" end

		else markup = markup .. "?" end
		
		markup = markup .. "</span>"
		w.markup = markup
			
		-- Set percentage and color
		a.value = percentage
		a.colors = {"#"..color.rgb_to_hex{
			r=red.r + (green.r - red.r) * percentage / 100,
			g=red.g + (green.g - red.g) * percentage / 100,
			b=red.b + (green.b - red.b) * percentage / 100
		}}

		a:emit_signal("widget::redraw_needed")
	end)


	return l
end

local last_color = color.color {r=232, g=87, b=87}
local next_color = color.color {r=232, g=87, b=87}
last_color.h = last_color.h - 40

local function create_volume_widget()
	local w = wibox.widget {
		markup = "墳",
		align = "center",
		widget = wibox.widget.textbox
	}

	local a = wibox.widget {
		w,
		min_value = 0,
		max_value = 100,
		value = 100,
		start_angle = 1.5 * math.pi,
		border_width = 0,
		rounded_edge = true,
		colors = {beautiful.light_gray},
		widget = wibox.container.arcchart
	}

	local l = wibox.widget {
		a,
		top = 2,
		bottom = 2,
		widget = wibox.container.margin
	}

	local prev_pos = 0

	local arc_timed = rubato.timed {
		duration = 0.2,
		intro = 0.3,
		prop_intro = true
	}

	arc_timed:subscribe(function(pos)
		pos = round(pos, 5)

		local value

		--If it's zero just display as blank and quit
		--weirdness because goddamn floats
		if pos == 0 then 
			a.colors = {"#ffffff00"} 
			return 
		end

		if pos % 100 == 0 then value = 100
		else value = pos % 100 end
		
		a.value = 7.5 + value * 0.925

		if prev_pos > 200 or pos > 200 then 
			local closest_hundred = round(pos, -2)
			if pos > closest_hundred and prev_pos <= closest_hundred then
				naughty.notify {text="above"..pos.." ".. closest_hundred.." "..prev_pos}
				last_color.h = last_color.h + 40
				next_color.h = next_color.h + 40
			elseif pos <= closest_hundred and prev_pos > closest_hundred then
				naughty.notify {text="below"..pos.." ".. closest_hundred.." "..prev_pos}
				last_color.h = last_color.h - 40
				next_color.h = next_color.h - 40
			end
			a.bg = "#"..last_color.hex
			a.colors = {"#"..next_color.hex}
		end

		if 200 > pos and pos > 100 then
			a.bg = beautiful.light_gray
			a.colors = {"#"..color.rgb_to_hex{
				r=green.r + (red.r - green.r) * value / 100,
				g=green.g + (red.g - green.g) * value / 100,
				b=green.b + (red.b - green.b) * value / 100
			}}
		elseif pos < 100 then
			a.bg = nil
			a.colors = {beautiful.light_gray}
		end

		prev_pos = pos

	end)

	awesome.connect_signal("signal::volume", function(percentage, muted)

		arc_timed:set(percentage)

		local markup = "<span font='10'>"

		if muted then markup = markup .. "婢"
		else markup = markup .. "墳" end

		markup = markup .. "</span>"
		w.markup = markup
	end)

	return l
end

local function create_minimized_widget(s) --TODO

	local l = wibox.widget { layout = wibox.layout.fixed.horizontal }
	table.insert(l.children, make_circle_widget {r=1, g=1, b=1})

	client.connect_signal("property::minimized", function()
		table.insert(l.children, make_circle_widget {r=1, g=1, b=1})
		l:emit_signal("widget::redraw_needed")
		--[[for _, t in pairs(s.tags) do
			for _, c in pairs(t:clients()) do
				if c.minimized then
					print("hi")
					table.insert(l.children, make_circle_widget {r=1, g=1, b=1})
				end
			end
			l:emit_signal("widget::redraw_needed")
		end]]
	end)

	return l
end


local function create_navbar(s)

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

	local tasklist = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.allscreen,
		layout = {
			layout  = wibox.layout.fixed.horizontal
		},
		widget_template = {
			{
				{
					id = 'clienticon',
					widget = awful.widget.clienticon,
				},
				margin = 10,
				widget = wibox.container.margin
			},
			nil,
			create_callback = function(self, c, index, objects)
				self:get_children_by_id('clienticon')[1].client = c
			end,
			layout = wibox.layout.align.vertical,
		},
	}

	-- create wibar
    s.top_navbar = awful.wibar({ 
		position = "top", 
		screen = s, 
		height = variables.navbar_height
	})

	--wibar setup
	s.top_navbar:setup {
		{	{	{	{	create_taglist_widgets(s),
						create_slidey_thing(s),
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
			margins = dpi(4),
			layout = wibox.container.margin
		},
		wibox.widget.textclock("%H:%M"),
		{
			create_battery_widget(),
			create_volume_widget(),
			layout = wibox.layout.fixed.horizontal
		},
		--create_minimized_widget(s),
		--tasklist,
		layout = wibox.layout.align.horizontal,
	}
	
end


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

	create_navbar(s)
	set_wallpaper(s)
end)


