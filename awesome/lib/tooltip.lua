--- Tooltip library for awesomewm
local wibox = require "wibox"
local awful = require "awful"
local gears = require "gears"



local function create_tooltip(args)
	assert(args, "please provide some argument, even an empty table")
	local self = {}

	args.x = args.x or 100
	args.y = args.y or 50
	
	args.markup = args.markup or "<b>template text</b>\nhi"

	args.color = args.color or "#000000"
	args.text_color = args.text_color or nil
	
	local text = wibox.widget { 
		markup = args.markup,
		widget = wibox.widget.textbox
	}

	local arrow = wibox.widget {
		fit = function(self, context, width, height)
			return 10, 7.5 
		end,
		draw = function(self, context, cr, width, height)
			cr:set_source_rgba(0, 0, 0, 1)
			cr:move_to(width / 2 - 5, 7.5)
			cr:line_to(width / 2, 0)
			cr:line_to(width / 2 + 5, 7.5)
			cr:fill()
		end
	}

	local tt = awful.popup {
		widget = {
			arrow,
			{
				{
					text,

					left = 8,
					right = 8,
					top = 0,
					bottom = 4,

					bg = args.color,
					widget = wibox.container.margin
				},
				bg = args.color,
				shape = gears.shape.rounded_rect,
				widget = wibox.widget.background

			},
			layout = wibox.layout.fixed.vertical
		},
		x = 10, y = 50,
		bg = "#00000000", --transparent
		opacity = 0,
	}

	--get pos
	function self:get_pos() return tt.x, tt.y end

	--set pos
	function self:set_pos(x, y)
		tt.x = x or tt.x
		tt.y = y or tt.y
	end

	--set opacity
	function self:set_opacity(new) tt.widget.opacity = new end

	--get visibility
	function self:get_visibility() return tt.visible end

	--set visibility
	function self:set_visibility(new) tt.visible = new end

	return self
end 


return {
	create_tooltip = create_tooltip
}
