#!/bin/bash
# Debian-configs (RDEB) - GPL v3
# Copyright (C) 2026 Ralph (Ralph-zlt)
#
# Suíte de regressão 01 — dconf aplica as configs das extensões GNOME
# Bug original (2026-10-19): configs.sh não aplicava gnome/dconf.ini na VM
# (arcmenu/dash-to-panel subiam com defaults) porque `dconf load` falhava
# silenciosamente (`|| echo` engolia o erro). Política: REGRAS.md §2.
#
# Uso:
#   ./01-dconf-extensions.sh --static   # offline: valida dconf.ini × estado atual do repo
#   ./01-dconf-extensions.sh --vm       # dentro da sessão GNOME: aplica e compara o dconf real
#
# Baseline = arquivos ATUAIS do repo (mudanças intencionais do dono são o esperado).

set -u

BASE="$(cd "$(dirname "$0")/../.." && pwd)"
DCONF_INI="$BASE/gnome/dconf.ini"
EXT_TXT="$BASE/extensoes/extensoes.txt"

pass=0
fail=0
ok() { echo "PASS: $1"; pass=$((pass + 1)); }
no() { echo "FAIL: $1"; fail=$((fail + 1)); }

resumo() {
    echo
    echo "======================================="
    echo " Suíte 01 (dconf/extensões): $pass PASS, $fail FAIL"
    [ "$fail" -eq 0 ] && echo " RESULTADO: TUDO VERDE" || echo " RESULTADO: FALHAS ACIMA"
    echo "======================================="
    [ "$fail" -eq 0 ]
}

mode="${1:---static}"

case "$mode" in
--static)
    python3 - "$DCONF_INI" "$EXT_TXT" "$BASE/extensoes" <<'PY'
import ast
import os
import sys
from pathlib import Path

ini, ext_txt, ext_dir = (Path(p) for p in sys.argv[1:4])
fails = []

def ok(msg):
    print(f"PASS: {msg}")

def no(msg):
    print(f"FAIL: {msg}")
    fails.append(msg)

# --- 1. Parse do dconf.ini ------------------------------------------------
secoes = {}          # seção -> {chave: valor}
secao_atual = None
erros_parse = []
for i, linha in enumerate(ini.read_text(encoding="utf-8").splitlines(), 1):
    l = linha.strip()
    if not l:
        continue
    if l.startswith("[") and l.endswith("]"):
        secao_atual = l[1:-1]
        secoes.setdefault(secao_atual, {})
        continue
    if "=" not in l:
        erros_parse.append((i, f"linha sem '=': {l[:40]}"))
        continue
    k, v = l.split("=", 1)
    if secao_atual is None:
        erros_parse.append((i, "chave fora de seção"))
        continue
    secoes[secao_atual][k] = v

if erros_parse:
    for i, msg in erros_parse:
        no(f"dconf.ini linha {i}: {msg}")
else:
    ok(f"dconf.ini: estrutura válida ({len(secoes)} seções)")

# --- 2. GVariant válido (bare [] é aceito pelo dconf) ---------------------
try:
    from gi.repository import GLib
    tem_glib = True
except ImportError:
    tem_glib = False

bad_variant = []
for sec, kvs in secoes.items():
    for k, v in kvs.items():
        # BUG 2026-10-19: o dconf do Trixie é estrito — `[]` nu aborta o load
        # inteiro ("unable to infer type"). Array vazio exige tipo: `@as []`.
        if v.strip() == "[]":
            bad_variant.append((sec, k, "array vazio sem tipo ([] nu) — usar @as []"))
            continue
        if v.strip() == "@as []":
            continue
        if tem_glib:
            try:
                GLib.Variant.parse(None, v)
            except Exception as e:
                bad_variant.append((sec, k, str(e)[:60]))
        # fallback sem GLib: apenas paridade de aspas/colchetes
        elif v.count("'") % 2 != 0 or v.count("(") != v.count(")") or v.count("{") != v.count("}"):
            bad_variant.append((sec, k, "aspas/parênteses/chaves desbalanceados"))

if bad_variant:
    for sec, k, msg in bad_variant:
        no(f"GVariant inválido em [{sec}] {k}: {msg}")
else:
    ok(f"GVariant: todas as {sum(len(k) for k in secoes.values())} chaves válidas" if tem_glib
       else "GVariant: checagem leve (GLib indisponível) ok")

# --- 3. enabled-extensions == manifesto extensoes.txt ---------------------
uuids_txt = sorted(l.strip() for l in ext_txt.read_text().splitlines()
                   if l.strip() and not l.strip().startswith("#"))
try:
    habilitadas = sorted(ast.literal_eval(secoes["org/gnome/shell"]["enabled-extensions"]))
except Exception as e:
    habilitadas = None
    no(f"enabled-extensions ilegível: {e}")
if habilitadas is not None:
    if habilitadas == uuids_txt:
        ok(f"enabled-extensions == extensoes.txt ({len(uuids_txt)} UUIDs)")
    else:
        no(f"enabled-extensions diverge do manifesto: só no dconf={sorted(set(habilitadas)-set(uuids_txt))}, só no manifesto={sorted(set(uuids_txt)-set(habilitadas))}")

# --- 4. UUIDs habilitados existem vendored --------------------------------
for u in uuids_txt:
    (ok if (ext_dir / u / "metadata.json").is_file()
     else no)(f"extensão vendored presente: {u}")

# --- 5. Seções de extensão no dconf casam com schemas vendored ------------
schemas = {}
for d in sorted(os.listdir(ext_dir)):
    schemas_dir = ext_dir / d / "schemas"
    if not schemas_dir.is_dir():
        continue
    for f in schemas_dir.glob("*.gschema.xml"):
        schemas.setdefault(d, f.name.removesuffix(".gschema.xml"))  # id do schema
# uuid -> nome do schema (última componente do id)
nome_schema_por_uuid = {u: s.rsplit(".", 1)[-1] for u, s in schemas.items()}
secoes_ext = [s for s in secoes if s.startswith("org/gnome/shell/extensions/")]
for sec in secoes_ext:
    nome = sec.rstrip("/").rsplit("/", 1)[-1]
    if nome in nome_schema_por_uuid.values():
        ok(f"seção dconf [{sec}] casa com schema vendored")
    else:
        no(f"seção dconf [{sec}] não corresponde a nenhum schema vendored")

# --- 6. Zero referências a programas removidos (transição flatpak) --------
proibidos = ["brave", "stacer", "MissionCenter", "blur-my-shell",
             "YaST", "Pardus", "discoverrc", "neofetch"]
whitelist = ["tweak-kitty-terminal"]  # chave de schema da extensão fxgn, não é o kitty removido
conteudo = ini.read_text()
for p in proibidos:
    linhas = [l for l in conteudo.splitlines()
              if p.lower() in l.lower() and not any(w in l for w in whitelist)]
    (no if linhas else ok)(f"sem referência a '{p}' em dconf.ini")

print()
print(f"Suíte 01 --static: {len(fails)} falha(s)")
sys.exit(1 if fails else 0)
PY
    rc=$?
    echo
    if [ "$rc" -eq 0 ]; then
        echo "Suíte 01 --static: TUDO VERDE"
    else
        echo "Suíte 01 --static: FALHAS ACIMA (exit=$rc)"
    fi
    exit "$rc"
    ;;
--vm)
    # --- 0. Pré-requisitos (diagnóstico das causas prováveis do bug) -------
    if ! command -v dconf >/dev/null 2>&1; then
        no "binário 'dconf' ausente — CAUSA PROVÁVEL DO BUG. Corrija com: sudo apt install -y dconf-cli"
        resumo
        exit 1
    fi
    ok "binário dconf presente"
    if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
        no "sem DBUS_SESSION_BUS_ADDRESS — rode dentro da sessão GNOME (causa provável: dconf escreve sem notificar a sessão)"
        resumo
        exit 1
    fi
    ok "sessão D-Bus detectada"
    if ! command -v gsettings >/dev/null 2>&1; then
        no "gsettings ausente"
        resumo
        exit 1
    fi

    # --- 1. Extensões instaladas no usuário -------------------------------
    EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
    while IFS= read -r u; do
        [ -z "$u" ] && continue
        case "$u" in \#*) continue ;; esac
        if [ -f "$EXT_DIR/$u/metadata.json" ]; then
            ok "extensão instalada: $u"
        else
            no "extensão AUSENTE em ~/.local: $u (rodar instalar.sh antes)"
        fi
    done < <(grep -v '^$' "$EXT_TXT")

    # --- 2. Aplicar dconf com erro visível --------------------------------
    echo
    echo "Aplicando dconf load (erro real será exibido)..."
    ERRO_LOAD=$(mktemp)
    if ! dconf load / < "$DCONF_INI" 2>"$ERRO_LOAD"; then
        no "dconf load falhou: $(cat "$ERRO_LOAD")"
        rm -f "$ERRO_LOAD"
        resumo
        exit 1
    fi
    rm -f "$ERRO_LOAD"
    ok "dconf load executado sem erro"

    # --- 3. Comparação chave a chave: dconf real == dconf.ini -------------
    python3 - "$DCONF_INI" <<'PY' > /tmp/opencode/01-expected.tsv
import sys
from pathlib import Path
sec = None
for linha in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    l = linha.strip()
    if not l:
        continue
    if l.startswith("[") and l.endswith("]"):
        sec = l[1:-1]
        continue
    k, v = l.split("=", 1)
    print(f"{sec}/{k}\t{v}")
PY
    while IFS=$'\t' read -r caminho esperado; do
        obtido=$(dconf read "/$caminho" 2>/dev/null || true)
        obtido=${obtido:-}
        if [ "$obtido" = "$esperado" ]; then
            ok "/$caminho"
        else
            no "/$caminho esperado=$esperado obtido=${obtido:-<vazio>}"
        fi
    done < /tmp/opencode/01-expected.tsv

    # --- 4. Verificação end-to-end via gsettings --------------------------
    esperado_g=$(python3 -c "
import sys, ast
from pathlib import Path
sec=None
for linha in Path('$DCONF_INI').read_text().splitlines():
    l=linha.strip()
    if l.startswith('[') and l.endswith(']'): sec=l[1:-1]; continue
    if sec=='org/gnome/shell' and l.startswith('enabled-extensions='): print(l.split('=',1)[1]); break
")
    obtido_g=$(gsettings get org.gnome.shell enabled-extensions)
    if [ "$obtido_g" = "$esperado_g" ]; then
        ok "gsettings org.gnome.shell enabled-extensions confere"
    else
        no "gsettings enabled-extensions diverge: esperado=$esperado_g obtido=$obtido_g"
    fi

    resumo
    ;;
*)
    echo "Uso: $0 --static | --vm" >&2
    exit 2
    ;;
esac
