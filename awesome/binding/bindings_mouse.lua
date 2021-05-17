local awful = require("awful")
local mainmenu = require("deco.menu")
local gears = require("gears")

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

