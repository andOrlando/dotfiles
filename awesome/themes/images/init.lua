local dir = require("gears.filesystem").get_dir("config").."themes/images/"
local icons = {
	battery_10 = dir.."battery_10.png",
	battery_20 = dir.."battery_20.png",
	battery_30 = dir.."battery_30.png",
	battery_40 = dir.."battery_40.png",
	battery_50 = dir.."battery_50.png",
	battery_60 = dir.."battery_60.png",
	battery_70 = dir.."battery_70.png",
	battery_80 = dir.."battery_80.png",
	battery_90 = dir.."battery_90.png",
	battery_charging = dir.."battery_charging.png",
	battery_full = dir.."battery_full.png",
	battery_low = dir.."battery_low.png",
	battery_unknown = dir.."battery_unknown.png",
	volume_high = dir.."volume_high.png",
	volume_mid = dir.."volume_mid.png",
	volume_low = dir.."volume_low.png",
	volume_mute = dir.."volume_mute.png",
	cool_question_mark = dir.."cool_question_mark.png",
	calendar = dir.."calendar.png",
	lightbulb = dir.."lightbulb.png",
	lock = dir.."lock.png",
	scissors = dir.."scissors.png",
	theme = dir.."theme.png",
	wifi_0 = dir.."wifi_0.png",
	wifi_1 = dir.."wifi_1.png",
	wifi_2 = dir.."wifi_2.png",
	wifi_3 = dir.."wifi_3.png",
	brightness = dir.."brightness.png",
	cpu = dir.."cpu.png",
	ram = dir.."ram.png",
	ssd = dir.."ssd.png",
	pause = dir.."pause.png",
	skip_next = dir.."skip_next.png",
	skip_prev = dir.."skip_prev.png",
}

return function(table)
	for k, v in pairs(icons) do
		table[k] = v
	end
end
