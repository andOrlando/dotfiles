local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local awestore = require("awestore")


local function draw_arc(cr, height)
	cr:arc(height/2, height/2, dpi(5)*0.9, 0, math.pi*2)
	cr:fill()
end

local function dim(pos, w, r, g, b)
	w.draw = 
	function(self, context, cr, width, height)
		cr:set_source_rgb( 
			r - pos > 0 and r - pos or 0,
			g - pos > 0 and g - pos or 0,
			b - pos > 0 and b - pos or 0
		)
		draw_arc(cr, height)
	end
	w:emit_signal("widget::redraw_needed")
end

local function gray(pos, w, r, g, b, dest)
	w.draw =
	function(self, context, cr, width, height)
		cr:set_source_rgb(
			r > dest and r - (r - dest) * pos or r + (dest - r) * pos,
			g > dest and g - (g - dest) * pos or g + (dest - g) * pos,
			b > dest and b - (b - dest) * pos or b + (dest - b) * pos
		)
		draw_arc(cr, height)
	end
	w:emit_signal("widget::redraw_needed")
end

local function get_widget(r, g, b, c, buttons)
	-- r, g, b are floats from [0, 1]
	-- c is the client or nil, determines whether it should gray on unfocus
	-- buttons are the buttons

	local w = wibox.widget {
		fit = 
		function(self, context, width, height)
			return height, height
		end,

		draw = 
		function(self, context, cr, width, height)
			cr:set_source_rgb(r, g, b)
			draw_arc(cr, height)
		end,

		buttons = buttons,
		layout = wibox.widget.base.make_widget
	}

	--dimming stuff
	local dim_tween = awestore.tweened(0, {
		duration = 100,
		easing = awestore.easing.linear
	})

	dim_tween:subscribe(function(pos)
		dim(pos, w, r, g, b)
	end)

	w:connect_signal("mouse::enter", function()
		dim_tween:set(0.30)
	end)

	w:connect_signal("mouse::leave", function()
		dim_tween:set(0)
	end)

	--checks if client is given
	if not c then return w end

	--graying stuff
	local gray_tween = awestore.tweened(0, {
			duration = 300,
			easing = awestore.easing.linear
	})

	gray_tween:subscribe(function(pos)
		gray(pos, w, r, g, b, 0.60)
	end)

	c:connect_signal("focus", function()
		gray_tween:set(0)
	end)

	c:connect_signal("unfocus", function()
		gray_tween:set(1)
	end)
	
	--w.gray = function() gray_tween:set(1) end
	--w.ungray = function() gray_tween:set(0) end
	
	return w
end

local function create_name_widget(c)
	local w = wibox.widget {
		valign = "bottom",
		widget = wibox.widget.textbox
	}

	local gray_tweened = awestore.tweened(0.6, {
		duration = 300,
		easing = awestore.easing.linear
	})

	gray_tweened:subscribe(function(pos)
		w.markup = '<span foreground="#'..
			string.rep(string.format("%x", math.floor(pos * 255)), 3)
			..'">'..c.class..'</span>'
		w:emit_signal("widget::redraw_needed")
	end)

	c:connect_signal("focus", function()
		gray_tweened:set(1)
	end)
	
	c:connect_signal("unfocus", function()
		gray_tweened:set(0.6)
	end)

	return w
end

local function create_titlebars(c)

	--creates buttons for dragging
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", {raise = true})
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", {raise = true})
			awful.mouse.client.resize(c)
		end)
	)

		
	--creates titlebar
	awful.titlebar(c, {size=dpi(22)}) : setup {
		{
			create_name_widget(c),
			margins = dpi(2),
			top = dpi(3),
			left = dpi(4),
			buttons = buttons,
			widget = wibox.container.margin
		},
		{
			buttons = buttons,
			layout = wibox.layout.flex.horizontal
		},
		{
			--minimize dot
			get_widget(0, 1, 0, c,
				awful.button({}, 1, function() 
					c.focusable = false
					c.minimized = true
				end,
				function() c.focusable = true end)),

			--maximize dot
			get_widget(1, 1, 0, c,
				awful.button({}, 1, function()
					c.maximized = not c.maximized
				end)),

			--close dot
			get_widget(1, 0, 0, nil,
				awful.button({}, 1, function()
					c:kill()
				end)),

			layout = wibox.layout.fixed.horizontal
		},
		forced_height = dpi(25),
		layout = wibox.layout.align.horizontal
	}
end

--connects titlebar to clients
client.connect_signal("request::titlebars", create_titlebars)



