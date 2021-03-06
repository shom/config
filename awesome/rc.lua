-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("vicious")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init(awful.util.getdir("config") .. "/default/theme.lua")
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser = "chromium"
pcmanfm = "pcmanfm"
homebank = "homebank"
gvim = "gvim"
stardict = "stardict"
leafpad = "leafpad"
gimp = "gimp"
virtualbox = "VirtualBox"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  tags[s] ={}
  for tagnumber =1,5 do
      tags[s][tagnumber] = tag({ name= tagnumber,layout = layouts[1]})
      tags[s][tagnumber].screen = s
  end
    -- Each screen has its own tag table.
--    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
  tags[s][1].selected = true
end

tags[1][1].name = "web"
tags[1][2].name = "term"
tags[1][3].name = "irc"
tags[1][4].name = "music"
tags[1][5].name = "other"
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "terminal", terminal },
				    { "browser", browser },
				    { "virtualbox", virtualbox },
                                    { "pcmanfm", pcmanfm },
                                    { "stardict", stardict },
                                    { "gvim", gvim },
                                    { "leafpad", leafpad },
				    { "gimp", gimp },
				    { "homebank", homebank }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
spacer    = widget({ type = "textbox" })
spacer.text     = " "
separator = widget({ type = "imagebox" })
separator.image  = image(beautiful.widget_sep)

memicon   = widget({ type = "imagebox" })
memicon.image    = image(beautiful.widget_mem)
memwidget = awful.widget.progressbar()
memwidget:set_width(12)
memwidget:set_height(16)
memwidget:set_vertical(true)
memwidget:set_background_color("#494B4F")
memwidget:set_border_color(nil)
memwidget:set_color("#AECF96")
memwidget:set_gradient_colors({ "#AECF96", "#88A175", "#FF5656" })
vicious.register(memwidget, vicious.widgets.mem, "$1", 5)
 
cpuicon   = widget({ type = "imagebox" })
cpuicon.image    = image(beautiful.widget_cpu)
cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_height(16)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color("#AECF96")
cpuwidget:set_gradient_angle(0)
cpuwidget:set_gradient_colors({ "#FF5656","#88A175","#AECF96" })
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 1)
tzswidget = widget({ type = "textbox" })
vicious.register(tzswidget, vicious.widgets.thermal, "$1℃", 19, "thermal_zone0")

dnicon = widget({ type = "imagebox" })
upicon = widget({ type = "imagebox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)
netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net,
' <span color="#cf9494">${eth0 down_kb}KB</span> <span color="#87ab87">${eth0 up_kb}KB</span>', 1)

volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
volwidget = widget({ type = "textbox" })
vicious.register(volwidget, vicious.widgets.volume, "$1%", 2, "PCM")
volwidget:buttons(awful.util.table.join(
   awful.button({ }, 3, function () awful.util.spawn("xterm -e alsamixer") end),
   awful.button({ }, 1, function () awful.util.spawn("amixer -q set Master toggle")   end),
   awful.button({ }, 4, function () awful.util.spawn("amixer -q set PCM 1dB+", false) end),
   awful.button({ }, 5, function () awful.util.spawn("amixer -q set PCM 1dB-", false) end)
))


mpdwidget = widget({ type = "textbox" })
vicious.register(mpdwidget, vicious.widgets.mpd,
  function (widget, args)
    if   args["{state}"] == "Stop" then return ""
    else return '<span color="#0d91c5">MPD:</span> '..
           args["{Artist}"]..' - '.. args["{Title}"]
    end
  end)


-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = 16, screen = s })

    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
--          mylauncher,
            mytaglist[s],
--	    mylayoutbox[s],
	    separator,cpuicon,cpuwidget,spacer,tzswidget,
	    separator,memicon,memwidget,
	    separator,dnicon,netwidget,upicon,
	    separator,volicon,volwidget,
	    separator,mpdwidget,
	    spacer,
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
	mylayoutbox[s],
        mytextclock,
	s == 1 and mysystray or nil,
--        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "Escape", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
--    awful.key({ modkey,           }, "Escape",
--        function ()
--            awful.client.focus.history.previous()
--            if client.focus then
--                client.focus:raise()
--            end
--        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Applications
    awful.key({}, "XF86AudioPlay",            function () awful.util.spawn("ncmpcpp toggle")                  end), 
    awful.key({}, "XF86AudioStop",            function () awful.util.spawn("ncmpcpp stop")                    end),
    awful.key({}, "XF86AudioPrev",            function () awful.util.spawn("ncmpcpp prev")                    end),
    awful.key({}, "XF86AudioNext",            function () awful.util.spawn("ncmpcpp next")                    end),
    awful.key({}, "XF86AudioRaiseVolume",     function () awful.util.spawn("amixer -q set PCM 5%+ unmute")    end),
    awful.key({}, "XF86AudioLowerVolume",     function () awful.util.spawn("amixer -q set PCM 5%- unmute")    end),
    awful.key({modkey},"XF86AudioRaiseVolume",function () awful.util.spawn("amixer -q set Master 5%+ unmute") end),
    awful.key({modkey},"XF86AudioLowerVolume",function () awful.util.spawn("amixer -q set Master 5%- unmute") end),
    awful.key({}, "XF86AudioMute",            function () awful.util.spawn("amixer -q set Master toggle")     end), 
    awful.key({},         "XF86HomePage",     function () awful.util.spawn("chromium")                        end),
    awful.key({},             "XF86Mail",     function () awful.util.spawn("chromium http://mail.google.com") end),
 
    awful.key({ modkey,       }, "Print",     function () awful.util.spawn("scrot '%Y-%m-%d--%s_$wx$h_scrot.png' -e 'mv $f ~/images/scrot/ &amp; gpicview ~/images/scrot/$f'")       end),
    awful.key({ modkey,           }, "w",     function () awful.util.spawn("chromium")  end),
    awful.key({ modkey,           }, "r",     function () awful.util.spawn("gmrun")     end),
    awful.key({ modkey,           }, "f",     function () awful.util.spawn("pcmanfm")   end),
    awful.key({ modkey,           }, "e",     function () awful.util.spawn("pcmanfm")   end),
    awful.key({ modkey,           }, "z",     function () awful.util.spawn("xlock -mode puzzle -fg green -echokeys -echokey *") end),
    awful.key({ modkey,           }, "p",     function () awful.util.spawn("dmenu_run -i -b -nb '#000000' -nf '#FFFFFF' -sb '#FFFFFF' -sf '#000000'") end),

    -- Prompt
    awful.key({ modkey },            "F1",     function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "F2",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)


clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "feh" },
      properties = { floating = true } },
    { rule = { class = "VirtualBox" },
      properties = { floating = true } },
    { rule = { class = "pidgin" },
      properties = { floating = true } },
    { rule = { class = "Openfetion" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
	c.size_hints_honor = false
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
