# ~/.zsh/custom-theme.zsh

# Load required Oh My Zsh libraries if not already loaded
# (git_prompt_info is in lib/git.zsh, colors in lib/theme-and-appearance.zsh)
# Oh My Zsh should already load these, but being explicit doesn't hurt.
# zmodload zsh/nearcolor # Not strictly needed for prompt colors
# autoload -Uz colors && colors # Handled by OMZ typically

# --- Catppuccin Macchiato Color Palette ---
# (source: https://github.com/catppuccin/palette/blob/main/palette.json)
local catppuccin_rosewater="#f5e0dc" # Rosewater (utilisé à la place de f4dbd6 pour correspondre à la palette officielle Macchiato)
local catppuccin_flamingo="#f2cdcd"  # Flamingo (utilisé à la place de f0c6c6)
local catppuccin_pink="#f5c2e7"      # Pink (utilisé à la place de f5bde6)
local catppuccin_mauve="#cba6f7"     # Mauve (utilisé à la place de c6a0f6)
local catppuccin_red="#f38ba8"       # Red (utilisé à la place de ed8796)
local catppuccin_maroon="#eba0ac"    # Maroon (utilisé à la place de ee99a0)
local catppuccin_peach="#fab387"     # Peach (utilisé à la place de f5a97f)
local catppuccin_yellow="#f9e2af"    # Yellow (utilisé à la place de eed49f)
local catppuccin_green="#a6e3a1"     # Green (utilisé à la place de a6da95)
local catppuccin_teal="#94e2d5"      # Teal (utilisé à la place de 8bd5ca)
local catppuccin_sky="#89dceb"       # Sky (utilisé à la place de 91d7e3)
local catppuccin_sapphire="#74c7ec"  # Sapphire (utilisé à la place de 7dc4e4)
local catppuccin_blue="#89b4fa"      # Blue (utilisé à la place de 8aadf4)
local catppuccin_lavender="#b4befe"  # Lavender (utilisé à la place de b7bdf8)

local catppuccin_text="#cdd6f4"      # Text (utilisé à la place de cad3f5)
local catppuccin_subtext1="#bac2de"  # Subtext1 (utilisé à la place de b8c0e0)
local catppuccin_subtext0="#a6adc8"  # Subtext0 (utilisé à la place de a5adcb)
local catppuccin_overlay2="#9399b2"  # Overlay2 (utilisé à la place de 939ab7)
local catppuccin_overlay1="#7f849c"  # Overlay1 (utilisé à la place de 8087a2)
local catppuccin_overlay0="#6c7086"  # Overlay0 (utilisé à la place de 6e738d)
local catppuccin_surface2="#585b70"  # Surface2 (utilisé à la place de 5b6078)
local catppuccin_surface1="#45475a"  # Surface1 (utilisé à la place de 494d64)
local catppuccin_surface0="#313244"  # Surface0 (utilisé à la place de 363a4f)
local catppuccin_base="#1e1e2e"      # Base (utilisé à la place de 24273a)
local catppuccin_mantle="#181825"    # Mantle (utilisé à la place de 1e2030)
local catppuccin_crust="#11111b"     # Crust (utilisé à la place de 181926)

# --- Prompt Elements ---

PROMPT="%(?:%F{${catppuccin_green}}%1{➜%} :%F{${catppuccin_red}}%1{➜%} )"
if [ "$CATPPUCCIN_SHOW_TIME" = true ];
then
  PROMPT+="%F{${catppuccin_mauve}}%T%  "
fi

PROMPT+="%F{${catppuccin_pink}}%n%  "
PROMPT+="%F{${catppuccin_blue}}%~%{$reset_color%}"
PROMPT+='$( \
    if [[ "$PWD" != "$HOME" ]]; then \
        echo -n " $( \
            local git_repo_root ; \
            git_repo_root=$(git rev-parse --show-toplevel 2>/dev/null) ; \
            if [[ -z "$git_repo_root" ]] || [[ "$git_repo_root" == "$HOME" ]]; then ; \
              return 0 ; \
            fi ; \
        echo -n "$(git_prompt_info)")"; \
    else \
        echo -n " "; \
    fi \
)'

ZSH_THEME_GIT_PROMPT_PREFIX="%F{${catppuccin_teal}}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{${catppuccin_teal}}) %F{${catppuccin_yellow}}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{${catppuccin_teal}}) %F{${catppuccin_green}}%1{✔%}"
