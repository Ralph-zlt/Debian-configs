function show_welcome
    neofetch

    echo ""
    echo "📌 Atalhos principais (GNOME Terminal + fish):"
    echo "────────────────────────────"
    echo "Ctrl + Shift + T → Nova aba"
    echo "Ctrl + Shift + N → Nova janela"
    echo "Ctrl + D → Fechar sessão"
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
