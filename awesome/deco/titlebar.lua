local gears = require "gears"
local awful = require "awful"
local wibox = require "wibox"
local naughty = require "naughty"
local xresources = require "beautiful.xresources"
local dpi = xresources.apply_dpi
local awestore = require "awestore"
local interpolate = require("lib.interpolate").interpolate
local tooltip = require "lib.tooltip"

--- Draw a circle.
-- @param cr cairo, given by draw
-- @param height height, given by draw
-- @see get_widget
local function draw_arc(cr, height)
	cr:arc(height/2, height/2, dpi(5)*0.9, 0, math.pi*2)
	cr:fill()
end

--- Udpate the draw function with new colors.
-- @param w widget
-- @param r the red value [0, 1]
-- @param g the green value [0, 1]
-- @param b the blue value [0, 1]
-- @see get_widget
local function update_rgb(w, r, g, b)
	w.draw =
	function(self, context, cr, width, height)
		cr:set_source_rgb(
			r > 0 and r or 0,
			g > 0 and g or 0,
			b > 0 and b or 0
		)
		draw_arc(cr, height)
	end
	w:emit_signal("widget::redraw_needed")
end

--- Get a circular widget.
-- TODO: memoize colors: https://www.lua.org/pil/17.1.html
-- @param r the red value [0, 1]
-- @param g the green value [0, 1]
-- @param b the blue value [0, 1]
-- @param buttons list of `awful.button`s
-- @param[opt] args, list of arguments
--     @field gray the amount to gray it by [0, 1], needs client
--     @field dim the amount to dim it by [0, 1]
--     @field client the client the widget is attatched to
-- @return the circular widget
local function get_widget(r, g, b, buttons, args)
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

	if not args then return w end

	-- dimming and animation
	if args.dim then
		w.d_rgb = {r=0, g=0, b=0, dim=0} --change in rgb/dim
		
		--dim interpolator
		w.dim_intp = interpolate({ slope = 0.045 })

		table.insert(w.dim_intp.subscribed, function(pos)
			w.d_rgb.dim = pos
			update_rgb(w, 
				r + w.d_rgb.dim + w.d_rgb.r,
				g + w.d_rgb.dim + w.d_rgb.g,
				b + w.d_rgb.dim + w.d_rgb.b
			)
		end)

		w:connect_signal("mouse::enter", function() w.dim_intp:set(-args.dim) end)
		w:connect_signal("mouse::leave", function() w.dim_intp:set(0) end)
	end

	--graying and animation
	if args.gray then 
		assert(args.client, "if you want gray, specify a client c")

		--gray interpolator 
		w.gray_intp = interpolate({ slope = 0.1 })

		table.insert(w.gray_intp.subscribed, function(pos)
			w.d_rgb.r = (args.gray - r) * pos
			w.d_rgb.g = (args.gray - g) * pos
			w.d_rgb.b = (args.gray - b) * pos
			update_rgb(w, 
				r + w.d_rgb.dim + w.d_rgb.r,
				g + w.d_rgb.dim + w.d_rgb.g,
				b + w.d_rgb.dim + w.d_rgb.b
			)
		end)

		args.client:connect_signal("focus", function() w.gray_intp:set(0) end)
		args.client:connect_signal("unfocus", function() w.gray_intp:set(1) end)
	end
		
	return w
end

--- Get info dot widget.
-- @param c the client
-- @return the info dot
-- @see get_widget
local function get_info_dot(c)

	local w = get_widget(0.5, 0.5, 1, 
		awful.button({}, 1, function()
			c.ontop = not c.ontop
		end),
		{ dim = 0.1 })

	local tt = tooltip.create_tooltip {
		markup = "hiya"
	}

	w:connect_signal("mouse::enter", function() 
		gears.timer {
			timeout = 0.1,
			callback = function()
				print(mouse.current_widget_geometry) 
			end
		}:start()
	end)
	w:connect_signal("mouse::leave", function() end)
	
	return w
end

--- Create titlebars
-- @param c client
-- @see get_widget
-- @see get_info_dot
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
		--[[{
			create_name_widget(c),
			margins = dpi(2),
			top = dpi(3),
			left = dpi(4),
			buttons = buttons,
			widget = wibox.container.margin
		},]]
		get_info_dot(c),
		{
			buttons = buttons,
			layout = wibox.layout.flex.horizontal
		},
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
					c.maximized = not c.maximized
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
		forced_height = dpi(25),
		layout = wibox.layout.align.horizontal
	}
end

--connects titlebar to clients
client.connect_signal("request::titlebars", create_titlebars)

