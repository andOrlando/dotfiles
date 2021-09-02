local awful = require "awful"
local wibox = require "wibox"
---@diagnostic disable-next-line: unused-local
local naughty = require "naughty"
local rubato = require "lib.rubato"
local cairo = require("lgi").cairo
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi


--- Draw a circle.
local function draw_arc(cr, height)
	cr:arc(height/2, height/2, dpi(5), 0, math.pi*2)
	cr:fill()
end

--- Udpate the draw function with new colors.
local function update_rgb(w, r, g, b)
	function w:draw(_, cr, width, _)
		cr:set_source_rgb(
			r > 0 and r or 0,
			g > 0 and g or 0,
			b > 0 and b or 0
		)
		draw_arc(cr, width)
	end
	w:emit_signal("widget::redraw_needed")
end

--- Get a circular widget.
local function get_widget(r, g, b, buttons, args)
	local w = wibox.widget {
		buttons = buttons,
		layout = wibox.widget.base.make_widget
	}

	function w:fit(_, width, _) return width, width end
	function w:draw(_, cr, _, height)
		cr:set_source_rgb(r, g, b)
		draw_arc(cr, height)
	end

	if not args then return w end

	local d_rgb = {r=0, g=0, b=0, dim=0} --change in rgb/dim

	-- dimming and animation
	if args.dim then

		--dim interpolator
		local dim_timed = rubato.timed {
			intro = 0.1,
			duration = 0.3,
			easing = rubato.zero
		}

		dim_timed:subscribe(function(pos)
			d_rgb.dim = pos
			update_rgb(w,
				r + d_rgb.dim + d_rgb.r,
				g + d_rgb.dim + d_rgb.g,
				b + d_rgb.dim + d_rgb.b
			)
		end)

		w:connect_signal("mouse::enter", function() dim_timed.target = -args.dim end)
		w:connect_signal("mouse::leave", function() dim_timed.target = 0 end)
	end

	--graying and animation
	if args.gray then
		assert(args.client, "if you want gray, specify a client c")

		--gray interpolator
		local gray_timed = rubato.timed {
			intro = 0.1,
			duration = 0.3,
			pos = 1,
			easing = rubato.zero
		}

		gray_timed:subscribe(function(pos)
			d_rgb.r = (args.gray - r) * pos
			d_rgb.g = (args.gray - g) * pos
			d_rgb.b = (args.gray - b) * pos
			update_rgb(w,
				r + d_rgb.dim + d_rgb.r,
				g + d_rgb.dim + d_rgb.g,
				b + d_rgb.dim + d_rgb.b
			)
		end)

		args.client:connect_signal("focus", function() gray_timed.target = 0 end)
		args.client:connect_signal("unfocus", function() gray_timed.target = 1 end)
	end

	return w
end

--beautiful.bg_normal colors as floats from 0 to 1
local rgb = {
	r = tonumber("0x"..beautiful.bg_normal:sub(2, 3)) / 256,
	g = tonumber("0x"..beautiful.bg_normal:sub(4, 5)) / 256,
	b = tonumber("0x"..beautiful.bg_normal:sub(6, 7)) / 256
}

--- Gets the middle widget
---@diagnostic disable-next-line: unused-function, unused-local
local function get_middle_widget(c)

	local w = wibox.widget {
		{
			wibox.widget {
				markup = c.class,
				widget = wibox.widget.textbox
			},
			left = dpi(15),
			widget = wibox.container.margin
		},
		{
			fit = function(_, _, width, height)
				return width, height
			end,

			draw = function(_, _, cr, _, height)
				local pattern = cairo.LinearPattern(0, 0, height * 0.5, 0)
				pattern:add_color_stop_rgba(0, rgb.r, rgb.g, rgb.b, 1)
				pattern:add_color_stop_rgba(1, rgb.r, rgb.g, rgb.b, 0)
				cr:rectangle(0, 0, height * 0.5, height)
				cr:set_source(pattern)
				cr:fill()
			end,

			widget = wibox.widget.base.make_widget
		},


		layout = wibox.layout.stack
	}

	local width, height = w.children[1].widget:get_preferred_size()

	local timed = rubato.timed {
		prop_intro = true,
		intro = 0.5,
		duration = 0.25,
		pos = -1 * width
	}

	timed:subscribe(function(pos)
		w.children[1].left = pos
		w.children[1]:emit_signal("widget::redraw_needed")
	end)

	c:connect_signal("focus", function() timed.target = 0.5 * height end)
	c:connect_signal("unfocus", function() timed.target = -1 * width end)

	return w
end

--- Get info dot widget.
local function get_info_dot(c)

	local w = get_widget(0.5, 0.5, 1,
		awful.button({}, 1, function()
			c.ontop = not c.ontop
		end),
		{ dim = 0.1 })

	w:connect_signal("mouse::enter", function() end)
	w:connect_signal("mouse::leave", function() end)

	--background must be filled for the middle widget to work
	local b = wibox.widget {}

	function b:fit(_, width, _) return width, width end
	function b:draw(_, cr, width, _)
		cr:rectangle(0, 0, width, width)
		cr:set_source_rgb(rgb.r, rgb.g, rgb.b)
		cr:fill()
	end

	return {
		b,
		w,
		layout = wibox.layout.stack
	}
end

--- Create titlebars
local function create_titlebars(c)

	--has two layers so that I can have the fade out animation
	--the top layer has the blue dot and it's opaque background
	--the bottom layer has everything else
	--[[local bottom_layer = {
		{ --dummy space-taking widget
			fit = function(_, _, w, h) return h, h end,
			widget = wibox.widget.base.make_widget
		},
		get_middle_widget(c),
		{
			--minimize dot
			get_widget(0, 1, 0,
				awful.button({}, 1, function()
					c.focusable = false
					c.minimized = true
				end,
				function() c.focusable = true end),
				{ dim = 0.3, gray = 0.6, client = c }),

			--maximize dot
			get_widget(1, 1, 0,
				awful.button({}, 1, function()
					c.fullscreen = not c.fullscreen
				end),
				{ dim = 0.3, gray = 0.6, client = c }),

			--close dot
			get_widget(1, 0, 0,
				awful.button({}, 1, function()
					c:kill()
				end),
				{ dim = 0.3 }),

			layout = wibox.layout.fixed.horizontal
		},
		layout = wibox.layout.align.horizontal
	}

	--top layer has the draggable stuff
	local top_layer = {
		get_info_dot(c),
		{
			fit = function(_, _, w, h) return w, h end,
			widget = wibox.widget.base.make_widget,

			buttons = gears.table.join(
				awful.button({}, 1, function()
					c:emit_signal("request::activate", "titlebar", {raise = true})
					awful.mouse.client.move(c)
				end),
				awful.button({}, 3, function()
					c:emit_signal("request::activate", "titlebar", {raise = true})
					awful.mouse.client.resize(c)
				end)),

		},
		{
			fit = function(_, _, w, h) return h * 3, h end,
			widget = wibox.widget.base.make_widget
		},
		layout = wibox.layout.align.horizontal
	}]]

	--creates titlebar
	--[[awful.titlebar(c, {size=dpi(22)}) : setup {
		bottom_layer,
		top_layer,
		layout = wibox.layout.stack
	}]]

	awful.titlebar(c, {size=dpi(30), position="left"}) : setup {
		{	--close dot
			get_widget(1, 0, 0,
				awful.button({}, 1, function() c:kill() end),
				{ dim = 0.3 }),

			--maximize dot
			get_widget(1, 1, 0,
				awful.button({}, 1, function() c.fullscreen = not c.fullscreen end),
				{ dim = 0.3, gray = 0.6, client = c }),

			--minimize dot
			get_widget(0, 1, 0,
				awful.button({}, 1, function()
					c.focusable = false
					c.minimized = true
				end,
				function() c.focusable = true end),
				{ dim = 0.3, gray = 0.6, client = c }),

			layout = wibox.layout.fixed.vertical

		},
		wibox.widget {},
		get_info_dot(c),
		layout = wibox.layout.align.vertical
	}
end

--connects titlebar to clients
client.connect_signal("request::titlebars", create_titlebars)

