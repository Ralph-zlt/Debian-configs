function fish_greeting
    fastfetch
end

function clear_and_welcome
    printf "\033c"
    fastfetch
    commandline -f repaint
end

bind \cl clear_and_welcome
