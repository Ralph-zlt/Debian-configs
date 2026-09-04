function show_welcome
    neofetch

    echo ""
    echo "📌 Atalhos principais:"
    echo "────────────────────────────"
    echo "Ctrl + Shift + D → Split lateral (Kitty)"
    echo "Ctrl + Shift + Enter → Split vertical"
    echo "Ctrl + D → Fechar split"
    echo "Ctrl + U → Apagar linha (início)"
    echo "Ctrl + K → Apagar até o fim"
    echo "Ctrl + L → Limpar tela"
    echo "────────────────────────────"
    echo ""
end

function fish_greeting
    show_welcome
end

function clear_and_welcome
    printf "\033c"
    show_welcome
    commandline -f repaint
end

bind \cl clear_and_welcome
