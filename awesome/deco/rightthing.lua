local awful = require 'awful'
local wibox = require 'wibox'
local variables = require 'main.variables'
local naughty = require 'naughty'
local rubato = require 'lib.rubato'
local dpi = require('beautiful.xresources').apply_dpi
local gears = require 'gears'
local beautiful = require 'beautiful'
local color = require 'lib.color'
local slider = require 'deco.widgets.slider'

local function create_music_widget(s_dpi)

	local art = wibox.widget {
		image = nil, --TODO: Get actual picture for this
		resize = true,
		forced_height = dpi(80),
		forced_width = dpi(80),
		buttons = {awful.button({}, 1, function()
		end)},
		widget = wibox.widget.imagebox
	}

	local function headerize(str) return "<span font='13' color='".."#ffffff".."'>"..str.."</span>" end
	local function subheaderize(str) return "<span font='10' color='".."#aaaaaa".."'>"..str.."</span>" end

	local title_widget = wibox.widget.textbox(headerize("No media playing"))
	local artist_widget = wibox.widget.textbox("")
	title_widget.ellipsize = "end"
	artist_widget.ellipsize = "end"

	local _, t_height = title_widget:get_preferred_size_at_dpi(s_dpi)
	local _, a_height = title_widget:get_preferred_size_at_dpi(s_dpi)

	local playpause_widget = require("lib.awesome-widgets.playpause") {
		forced_width = dpi(25),
		forced_height = dpi(25),
		button = awful.button({}, 1, function() awful.spawn("playerctl play-pause") end),
	}

	--sets playpause status based off playerctl
	local function set_playpause_status()
		awful.spawn.with_line_callback("playerctl status", {
			stdout = function(string)
				if string == "Paused" then playpause_widget:set(1)
				else playpause_widget:set(0) end
			end
		})
	end

	set_playpause_status()

	-- Get Song Info
	awesome.connect_signal("bling::playerctl::title_artist_album",
	function(title, artist, art_path, player_name)
		art:set_image(gears.surface.load_uncached(art_path or nil))
		title_widget:set_markup_silently(headerize(title or "No Title"))
		artist_widget:set_markup_silently(subheaderize((artist and artist.." via " or "")..player_name))

		set_playpause_status()
	end)

	awesome.connect_signal("bling::playerctl::no_players",
	function()
		art:set_image(nil)
		title_widget:set_markup_silently("No media playing")
		artist_widget:set_markup_silently("")

		set_playpause_status()
	end)

	--[[awesome.connect_signal("bling::playerctl::position",
	function(interval_sec, length_sec)
		naughty.notify {text=tostring(interval_sec).." "..tostring(length_sec)}
	end)]]



	return
	{
		{
			art,
			shape = gears.shape.rounded_rect,
			shape_clip = true,
			bg = beautiful.bg_normal_1,
			layout = wibox.container.background
		},
		{
			{
				{
					{
						title_widget,
						strategy = "max",
						height = t_height,
						layout = wibox.container.constraint
					},
					{
						artist_widget,
						strategy = "max",
						height = a_height,
						layout = wibox.container.constraint
					},
					layout = wibox.layout.fixed.vertical
				},
				left = dpi(8),
				layout = wibox.container.margin
			},
			{
				{
					{
						{
							{
								{
									image = beautiful.skip_prev,
									forced_width = dpi(25),
									forced_height = dpi(25),
									widget = wibox.widget.imagebox
								},
								--[[{
									image = beautiful.pause,
									forced_width = dpi(25),
									forced_height = dpi(25),
									widget = wibox.widget.imagebox
								},]]
								playpause_widget,
								{
									image = beautiful.skip_next,
									forced_width = dpi(25),
									forced_height = dpi(25),
									widget = wibox.widget.imagebox
								},
								layout = wibox.layout.fixed.horizontal
							},
							margins = dpi(4),
							layout = wibox.container.margin
						},
						shape = gears.shape.rounded_rect,
						bg = beautiful.bg_normal_1,
						layout = wibox.container.background
					},
					--margins = dpi(4),
					layout = wibox.container.margin
				},
				valign = "bottom",
				halign = "right",
				layout = wibox.container.place
			},
			layout = wibox.layout.stack
		},
		fill_space = true,
		layout = wibox.layout.fixed.horizontal,
	}

end

local function create_brightness_widget()

	local brightness_slider = slider {
		lw_margins = dpi(20),
		height_bar = dpi(8),
		height_handle = dpi(14),

		forced_height = dpi(40),
	}

	awful.spawn.with_line_callback("xbacklight", {
		stdout = function(out) brightness_slider:hard_set(out/100) end
	})

	local image = wibox.widget {
		{
			{
				image = beautiful.brightness,
				forced_width = dpi(20),
				forced_height = dpi(20),
				widget = wibox.widget.imagebox
			},
			margins = dpi(12),
			layout = wibox.container.margin
		},
		shape = gears.shape.rounded_rect,
		bg = beautiful.bg_normal_1.."64",
		layout = wibox.container.background
	}

	brightness_slider:connect_signal("slider::moved", function(_, pos)
		awful.spawn("xbacklight -time 0 -set "..math.floor(5 + pos * 95))
	end)


	return {
		{
			wibox.widget {}, --TODO: Make more idiomatic
			brightness_slider,
			image,
			layout = wibox.layout.align.horizontal
		},
		right = dpi(20),
		layout = wibox.container.margin
	}
end

local function create_volume_widget()
	local volume_slider = slider {
		lw_margins = dpi(20),
		height_bar = dpi(8),
		height_handle = dpi(14),

		forced_height = dpi(40),
	}

	local button = wibox.widget {
		{
			{
				image = beautiful.volume_high,
				forced_width = dpi(24),
				forced_height = dpi(24),
				widget = wibox.widget.imagebox
			},
			margins = dpi(10),
			layout = wibox.container.margin
		},
		shape = gears.shape.rounded_rect,
		bg = beautiful.bg_normal_1.."64",
		layout = wibox.container.background
	}

	local volume_first = false
	local slider_first = false
	local finished_setting = true

	awesome.connect_signal("signal::volume", function(percentage)
		if finished_setting then
			if not slider_first then volume_first = true end
			if volume_first then
				volume_slider:set(math.min(percentage, 100)/100)
			end
		end
	end)

	volume_slider:connect_signal("slider::moved", function(_, pos)
		if not volume_first then slider_first = true end
		if slider_first then
			finished_setting = false
			awful.spawn.with_line_callback("pactl set-sink-volume @DEFAULT_SINK@ "..math.floor(pos * 100).."%", {
				exit = function()
					finished_setting = true
				end
			})
		end
	end)

	volume_slider:connect_signal("slider::ended", function()
		slider_first = false
		volume_first = false
	end)

	return {
		{
			wibox.widget {},
			volume_slider,
			button,
			layout = wibox.layout.align.horizontal
		},
		right = dpi(20),
		layout = wibox.container.margin
	}
end

local off_rgb, on_rgb = {}, {}
off_rgb.r, off_rgb.g, off_rgb.b = color.hex_to_rgb(beautiful.bg_normal_1)
on_rgb.r, on_rgb.g, on_rgb.b = color.hex_to_rgb(beautiful.light_blue)

--Toggle is automatically switched because I gotta do some other stuff too
local function toggle_button(icon, button, reset_on_leave)

	--early initialization so it can be used in w's initialization
	local rgb_timed

	local d = { r=0, g=0, b=0, dim=0 }
	local final = color.color {disable_hsl = true}

	icon = icon or beautiful.battery_charging
	local w = wibox.widget {
		{
			{
				image = icon,
				widget = wibox.widget.imagebox
			},
			margins = dpi(13),
			layout = wibox.container.margin
		},
		forced_height = dpi(50),
		forced_width = dpi(50),

		shape = gears.shape.rounded_rect,
		bg = beautiful.bg_normal_1,
		buttons = button,
		layout = wibox.container.background
	}

	function w:update_colors()
		final.r = (off_rgb.r - d.r) * d.dim
		final.g = (off_rgb.g - d.g) * d.dim
		final.b = (off_rgb.b - d.b) * d.dim
		self.bg = final.hex
		self:emit_signal("widget::redraw_needed")
	end

	local hover_timed = rubato.timed {
		duration = 0.2,
		intro = 0.3,
		prop_intro = true,
		subscribed = function(pos)
			d.dim = 1 - pos
			w:update_colors()
		end
	}

	rgb_timed = rubato.timed {
		duration = 0.2,
		intro = 0.3,
		prop_intro = true,
		subscribed = function(pos)
			d.r = (off_rgb.r - on_rgb.r) * pos
			d.g = (off_rgb.g - on_rgb.g) * pos
			d.b = (off_rgb.b - on_rgb.b) * pos
			w:update_colors()
		end
	}

	w:connect_signal("mouse::enter", function() hover_timed.target = 0.2 end)
	w:connect_signal("mouse::leave", function()
		hover_timed.target = 0
		if reset_on_leave then rgb_timed.target = 0 end
	end)

	local function rgb(value) rgb_timed.target = value end
	local function hover(value) hover_timed.target = value end

	return {
		{
			w,
			margins = dpi(8),
			layout = wibox.container.margin
		},
		halign = "center",
		layout = wibox.container.place,

		--manual set functions
		rgb = rgb,
		hover = hover,
	}

end

local function create_storage_widget(image, signal)
	local pb = wibox.widget {
		forced_height = dpi(10),
		forced_width = dpi(100),

		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,

		color = "#aaaaaa",
		background_color = beautiful.bg_normal_1,
		value = 0.3,

		widget = wibox.widget.progressbar
	}

	awesome.connect_signal(signal, function(used, available)
		pb.value = used / (available or 100)
	end)

	return {
		{
			pb,
			valign = "center",
			widget = wibox.container.place
		},
		{
			image = beautiful[image],
			forced_height = dpi(18),
			forced_width = dpi(18),
			widget = wibox.widget.imagebox
		},
		spacing = dpi(20),
		layout = wibox.layout.fixed.horizontal
	}
end

local function create_card(w)
	return {
		w,
		shape = gears.shape.rounded_rect,
		bg = beautiful.bg_normal,
		layout = wibox.container.background
	}
end

return function(s)

	local rightthing

	local toggle = {
		blue = 0,
		theme = 0,
		wifi = 0,
	}

	local blue_light_toggle
	blue_light_toggle = toggle_button(beautiful.lightbulb, awful.button({}, 1, function()
			toggle.blue = (toggle.blue + 1) % 2
			awful.spawn("sct "..tostring(6500 - toggle.blue * 2000))
			blue_light_toggle.rgb(toggle.blue)
		end)
	)

	local screenshot_button
	screenshot_button = toggle_button(beautiful.scissors, awful.button({}, 1,
		function()
			screenshot_button.rgb(1)
		end,
		function()
			screenshot_button.rgb(0)
			rightthing:set(0)
			awful.spawn("shutter -s --delay=3")
		end), true
	)

	local media_card = create_card {
		create_music_widget(s.dpi),
		margins = dpi(10),
		layout = wibox.container.margin
	}

	local dashboard_card = create_card {
		{
			{
				{
					blue_light_toggle,
					toggle_button(beautiful.lock),
					screenshot_button,
					layout = wibox.layout.flex.horizontal
				},
				{
					toggle_button(beautiful.theme),
					toggle_button(beautiful.calendar),
					toggle_button(beautiful.wifi_3),
					layout = wibox.layout.flex.horizontal
				},
				spacing = dpi(5),
				layout = wibox.layout.fixed.vertical
			},
			left = dpi(40),
			right = dpi(40),
			top = dpi(10),
			--bottom = dpi(10),
			layout = wibox.layout.margin --buttons
		},
		create_brightness_widget(),
		create_volume_widget(),
		wibox.widget {}, --just a spacing widget, adds 10dpi of space cuz spacing
		spacing = dpi(10),
		layout = wibox.layout.fixed.vertical --sections within card
	}

	local device_info_card = create_card {
		{
			{
				create_storage_widget("cpu", "signal::cpu"),
				create_storage_widget("ram", "signal::ram"),
				create_storage_widget("ssd", "signal::disk"),
				spacing = dpi(10),
				layout = wibox.layout.fixed.vertical
			},
			margins = dpi(10),
			layout = wibox.container.margin
		},
		shape = gears.shape.rounded_rect,
		bg = beautiful.bg_normal,
		layout = wibox.container.background --card TODO: Add more stuff to this card
	}

	--[[local notification_widget =  {
		{

			naughty.widget.title,
			naughty.widget.message,
			layout = wibox.layout.fixed.vertical
		},
		base_layout = wibox.layout.fixed.vertical,
		widget = naughty.list.notifications
	}]]

	local notification_card = create_card ()--notification_widget)

	--notification_widget.base_layout = wibox.layout.fixed.horizontal


	rightthing = awful.popup {
		widget = {
			{
				{
					media_card,
					dashboard_card,
					device_info_card,
					spacing = dpi(5),
					layout = wibox.layout.fixed.vertical --stacked cards
				},
				{
					notification_card,
					top = dpi(5),
					bottom = dpi(5),
					layout = wibox.container.margin

				},
				layout = wibox.layout.align.vertical
			},
			margins = dpi(5),
			layout = wibox.container.margin --transparent margin
		},
		screen = s,
		maximum_height = s.geometry.height - variables.top_navbar_height,
		minimum_height = s.geometry.height - variables.top_navbar_height,
		maximum_width = dpi(400),
		minimum_width = dpi(400),
		bg = "#00000000",
		y = variables.top_navbar_height + variables.top_navbar_padding,
		ontop = true
	}

	local timed = rubato.timed {
		duration = 0.4,
		intro = 0.3,
		rate = 60,
		prop_intro = true,
		subscribed = function(pos)
			rightthing.x = s.geometry.width - rightthing.width * pos
		end
	}

	--0 is closed, 1 is open
	rightthing.closed_state = 0

	function rightthing:toggle()
		self.closed_state = (self.closed_state + 1) % 2
		timed.target = self.closed_state
	end

	function rightthing:set(value)
		self.closed_state = value
		timed.target = self.closed_state
	end

	return rightthing

end


