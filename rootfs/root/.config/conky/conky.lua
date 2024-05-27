conky.config = {
    update_interval = 1,
    double_buffer = true,

    alignment = 'top_right',
    gap_x = 5,
    gap_y = 5,
    minimum_width = 210,

    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_argb_visual = false,
    own_window_transparent = false,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

    background = true,
    border_width = 1,

    -- cpu_avg_samples = 2,
    -- net_avg_samples = 2,
    -- no_buffers = true,

    default_color = '#333333',
    default_shade_color = '#FFFFFF',
    default_outline_color = '#FFFFFF',

    draw_borders = true,
    draw_shades = false,
    draw_outline = false,
    draw_graph_borders = true,

    use_xft = true,
    xftalpha = 1,
    uppercase = false,
    override_utf8_locale = true,
    short_units = true,

    extra_newline = false,
    use_spacer = 'none',

    show_graph_scale = false,
    show_graph_range = false,

    -- Print everything to stdout/stderr?
    out_to_console = false,
    out_to_stderr = false,

    template0 = [[${color #FFFFFF}\2${alignr} ${if_mounted \1}${font Monospace:normal:size=8}${fs_used \1} | ${fs_free \1} ${font sans-serif:normal:size=8}
${color \3}${fs_bar 6 \1}${else}not mounted${endif}]],
    template1 = [[${color #FFFFFF}\2${alignr} ${if_mounted \1}${font Monospace:normal:size=8}Used: ${fs_used \1} | Free: ${fs_free \1} ${font sans-serif:normal:size=8}
${color \3}${fs_bar 6 \1}${else}not mounted${endif}]],
};

-- Title
conky.text = [[
${font Ubuntu:style=bold:size=11}${color #FFFFFF}${alignc}${execi 86400 lsb_release -ds}
${font sans-serif:bold:size=8}${color #008FCF}${stippled_hr}
]];

-- Devices
conky.text = conky.text .. [[
${font sans-serif:bold:size=8}${color #FFA300}DISKS ${color slate grey}${hr 2}${font sans-serif:normal:size=8}
${template0 / System #888888}
${template0 /root/Downloads Downloads #00AF00}
]];

-- Hardware
conky.text = conky.text .. [[
${font sans-serif:bold:size=8}${color #FFA300}HARDWARE ${color slate grey}${hr 2}${font sans-serif:normal:size=8}
${color #FFFFFF}CPU${alignr}${font Monospace:normal:size=8} ${cpu}%${font sans-serif:normal:size=8}
${color #FFFFFF}${cpubar 6 /}
${color #FFFFFF}RAM${alignr}${font Monospace:normal:size=8} ${mem} / ${memmax} | ${memperc}%${font sans-serif:normal:size=8}
${color #ddaa00}${membar 6 /}
${color #FFFFFF}Swap${alignr}${font Monospace:normal:size=8} ${swap} / ${swapmax} | ${swapperc}%${font sans-serif:normal:size=8}
${color #888888}${swapbar 6 /}
]];

-- Other
conky.text = conky.text .. [[
${font sans-serif:bold:size=8}${color #FFA300}OTHER ${color slate grey}${hr 2}${font sans-serif:normal:size=8}
${color #FFFFFF}Kernel:${alignr}${execi 86400 uname -r}
${color #FFFFFF}Codename:${alignr}${execi 86400 lsb_release -cs}
]];

