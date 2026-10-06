function fish_greeting
    neofetch
end

function clear_and_welcome
    printf "\033c"
    neofetch
    commandline -f repaint
end

bind \cl clear_and_welcome
