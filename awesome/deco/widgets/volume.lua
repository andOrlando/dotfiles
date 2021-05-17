local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local vars = require("main.variables")

function get_volume_widget(full_height, bar_height, width)
	local bar = wibox.widget {
		max_value = 1,
		shape = gears.shape.rounded_bar,
		bar_shape = geras.shape.rounded_bar,
		border_color = beaufitul.border_color,
		widget = wibox.widget.progressbar,
	}
	local padding = (full_hegith - bar_height) / 2
	local widget = wibox.widget {
		bar,
		forced_width = width,
		top = padding,
		bottom = padding,
		widget = wibox.widget.progressbar,
	}
	awesome.connect_signal()
end

test = wibox.widget {
	{
		max_value = 1,
		value = 0.3,
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,
		border_color = beautiful.border_color,
		widget = wibox.widget.progressbar,
	},
	forced_width = 24,
	top = 4,
	bottom = 4,
	layout = wibox.container.margin,
}
