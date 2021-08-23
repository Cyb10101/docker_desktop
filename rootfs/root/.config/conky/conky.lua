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

    -- # Print everything to stdout/stderr?
    out_to_console = false,
    out_to_stderr = false,
};

-- Title
conky.text = [[
${font Ubuntu:style=bold:size=11}${color #FFFFFF}${alignc}${execi 30 lsb_release -ds} (${execi 30 lsb_release -cs})
${font sans-serif:bold:size=8}${color #008FCF}${stippled_hr}
]];

-- Devices
conky.text = conky.text .. [[
${font sans-serif:bold:size=8}${color #FFA300}DISKS ${color slate grey}${hr 2}${font sans-serif:normal:size=8}
${color #FFFFFF}System${alignr}Used: ${fs_used /} | Free: ${fs_free /}
${color #888888}${fs_bar 6 /}
${color #FFFFFF}Downloads${alignr}Used: ${fs_used /root/Downloads} | Free: ${fs_free /root/Downloads}
${color #00AF00}${fs_bar 6 /root/Downloads}
]];

-- Hardware
conky.text = conky.text .. [[
${font sans-serif:bold:size=8}${color #FFA300}HARDWARE ${color slate grey}${hr 2}${font sans-serif:normal:size=8}
${color #FFFFFF}CPU${alignr} ${cpu}%
${color #FFFFFF}${cpubar 6 /}
${color #FFFFFF}RAM${alignr} ${mem} / ${memmax}     ${memperc}%
${color #ddaa00}${membar 6 /}
${color #FFFFFF}Swap${alignr} ${swap} / ${swapmax}     ${swapperc}%
${color #888888}${swapbar 6 /}
]];
