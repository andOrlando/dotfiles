local dir = require("gears.filesystem").get_dir("config").."themes/icons/"
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
	volume_mute = dir.."volume_mute.png"
}

return function(table)
	for k, v in pairs(icons) do
		table[k] = v
	end
end
