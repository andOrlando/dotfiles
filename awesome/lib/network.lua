-- Provides:
-- daemons::network::wired::disconnected
--      (No parameters)
-- daemons::network::wireless::disconnected
--      (No parameters)
-- daemons::network::wired::connected
--      interface (string)
--      health (bool)
-- daemons::network::wireless::connected
--      essid (string)
--      interface (string)
--      strength (number)
--      strength_level (number)
--      bitrate (number)
--      healthy (bool)

local awful = require("awful")
local gears = require("gears")

local update_interval = 2
local interfaces =
{
    wlan_interface = 'wlp4s0',
    lan_interface = 'enp0s25'
}

local network_mode = nil
local is_startup = true
local is_disconnected = true

local check_internet_health_script = [=[
	status_ping=0
	packets="$(ping -q -w2 -c2 1.1.1.1 | grep -o "100% packet loss")"
	if [ ! -z "${packets}" ];
	then
		status_ping=0
	else
		status_ping=1
	fi
	if [ $status_ping -eq 0 ];
	then
		echo 'Connected but no internet'
	fi
]=]

local update_wireless = function()
    network_mode = 'wireless'

    local update_wireless_data = function(strength, strength_level, healthy)
        awful.spawn.easy_async_with_shell("iwconfig", function(stdout)
            local essid = stdout:match('ESSID:(.-)\n') or 'N/A'
            essid = essid:gsub("%\"", "")
            local bitrate = stdout:match('Bit Rate=(.+/s)') or 'N/A'

            if essid:match("off/any") == nil and healthy and (is_disconnected or is_startup) then
                awesome.emit_signal('daemons::network::wireless::connected', essid, interfaces.wlan_interface, strength, strength_level, bitrate, healthy)
                is_disconnected = false
            end
            is_startup = false
        end)
    end

    local update_wireless_connection_state = function(strength, strength_level)
        awful.spawn.easy_async_with_shell(check_internet_health_script, function(stdout)
            if not stdout:match('Connected but no internet') then
                update_wireless_data(strength, strength_level, true)
            else
                update_wireless_data(strength, strength_level, false)
            end
        end)
    end

    local update_wireless_strength = function()
        awful.spawn.easy_async_with_shell([[awk 'NR==3 {printf "%3.0f" ,($3/70)*100}' /proc/net/wireless]], function(stdout)
            if not tonumber(stdout) then
                return
            end
            local strength = tonumber(stdout)
            local strength_level = math.floor(strength / 25 + 0.5)
            update_wireless_connection_state(strength, strength_level)
        end)
    end

    update_wireless_strength()
    is_startup = false
end

local update_wired = function()
    network_mode = 'wired'

    awful.spawn.easy_async_with_shell(check_internet_health_script, function(stdout)
        if is_startup or is_disconnected then
            local healthy = stdout:match('Connected but no internet') and false or true
            awesome.emit_signal('daemons::network::wired::connected', interfaces.lan_interface, healthy)
            is_disconnected = false
        end
        is_startup = false
    end)
end

local update_disconnected = function()
    if network_mode == 'wireless' then
        if not is_disconnected then
            is_disconnected = true
            awesome.emit_signal("daemons::network::wireless::disconnected")
        end
    elseif network_mode == 'wired' then
        if not is_disconnected then
            is_disconnected = true
            awesome.emit_signal("daemons::network::wired::disconnected")
        end
    end
end

local check_network_mode = function()
    awful.spawn.easy_async_with_shell(
        [=[
        wireless="]=] .. tostring(interfaces.wlan_interface) .. [=["
        wired="]=] .. tostring(interfaces.lan_interface) .. [=["
        net="/sys/class/net/"
        wired_state="down"
        wireless_state="down"
        network_mode=""
        # Check network state based on interface's operstate value
        function check_network_state() {
            # Check what interface is up
            if [[ "${wireless_state}" == "up" ]];
            then
                network_mode='wireless'
            elif [[ "${wired_state}" == "up" ]];
            then
                network_mode='wired'
            else
                network_mode='No internet connection'
            fi
        }
        # Check if network directory exist
        function check_network_directory() {
            if [[ -n "${wireless}" && -d "${net}${wireless}" ]];
            then
                wireless_state="$(cat "${net}${wireless}/operstate")"
            fi
            if [[ -n "${wired}" && -d "${net}${wired}" ]]; then
                wired_state="$(cat "${net}${wired}/operstate")"
            fi
            check_network_state
        }
        # Start script
        function print_network_mode() {
            # Call to check network dir
            check_network_directory
            # Print network mode
            printf "${network_mode}"
        }
        print_network_mode
        ]=],
        function(stdout)
            local mode = stdout:gsub('%\n', '')
            if stdout:match('No internet connection') then
                update_disconnected()
            elseif stdout:match('wireless') then
                update_wireless()
            elseif stdout:match('wired') then
                update_wired()
            end
        end
    )
end

local network_updater = gears.timer { timeout = update_interval, autostart = true, call_now = true, callback = function()
    check_network_mode()
end}
