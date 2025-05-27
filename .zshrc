# metrics commented
#zmodload zsh/zprof

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Source .profile if it exists, to load common env variables and aliases
if [ -f "${HOME}/.profile" ]; then
  source "${HOME}/.profile"
fi




# --- Start Useful Aliases ---
alias ls='ls --color=auto'
alias ll='ls -lFh'    # Long list format, human-readable sizes, classify
alias la='ls -AlFh'   # Long list, show almost all (dotfiles), classify
alias l='ls -CF'      # List in columns, classify

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias c='clear'
alias h='history'
alias j='jobs -l'

# Git aliases 
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gs='git status'
# --- End Useful Aliases ---




# --- Start Zsh History Configuration ---
HISTFILE=~/.zsh_history      # Defines the location of the history file.
HISTSIZE=10000               # Number of history lines to keep in memory during the session.
SAVEHIST=10000               # Number of history lines to save in HISTFILE when the shell exits.
                               # It's common to set this to the same value as HISTSIZE.

setopt APPEND_HISTORY        # Appends history to the history file, instead of overwriting it each session.
setopt EXTENDED_HISTORY      # Records the timestamp and execution duration of commands.
setopt INC_APPEND_HISTORY    # Records each command in HISTFILE as soon as it's executed,
                               # not just at the end of the session. This is very useful.
setopt SHARE_HISTORY         # Shares history between all open Zsh sessions.
                               # If a command is typed in one terminal, it becomes available
                               # in others. Requires INC_APPEND_HISTORY.
setopt HIST_IGNORE_ALL_DUPS  # If the new command is identical to the previous one, don't record it.
# setopt HIST_IGNORE_DUPS    # Don't record consecutive duplicate commands (alternative to IGNORE_ALL_DUPS).
# setopt HIST_SAVE_NO_DUPS   # If multiple identical commands are in the session's history,
                               # only save one to HISTFILE.

# Your additions:
setopt HIST_EXPIRE_DUPS_FIRST # If history is full, delete duplicates first to make space.
setopt HIST_FIND_NO_DUPS   # When searching (Ctrl+R or arrows), don't show consecutive duplicates.

# Option HIST_REDUCE_BLANKS (generally safe and useful):
setopt HIST_REDUCE_BLANKS  # Remove superfluous blanks from commands before saving them to history.
# --- End Zsh History Configuration ---

# --- Start Enhanced Zsh Completion System ---
# Initialize the completion system
autoload -Uz compinit
compinit -C # Initialize and load completion definitions

# Enable caching of completion definitions to speed up shell startup
# The _compdump file will be created in ~/.zsh_compdump or similar
# You can control its location with compinit -d <path_to_dumpfile>
# compinit -C # Use cache if available, otherwise re-generate

# Enable menu completion: cycle through completions with Tab
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# Group completions by type
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{red}%d (errors: %e)%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}%d%f'
zstyle ':completion:*:messages' format ' %F{purple}%d%f'
zstyle ':completion:*:warnings' format ' %F{red}--- no matches found ---%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Case-insensitive completion
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Basic case-insensitivity
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} m:{A-Z}={a-z} r:|[-_./]=* r:|=*' # More robust

# Approximate completion (e.g., complete 'config' if you type 'confgi')
# zstyle ':completion:*' completer _complete _match _approximate
# zstyle ':completion:*:match:*' original only
# zstyle ':completion:*:approximate:*' max-errors 1 numeric # Allow one error

# Path completion enhancements
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'
# --- End Enhanced Zsh Completion System ---




# --- Start Useful Zsh Options (setopt) ---
setopt AUTO_CD              # Change directory by typing the directory name (if it's not a command)
setopt AUTO_PUSHD           # Automatically push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicate directories onto the stack
# setopt CDABLE_VARS          # If a command is a shell parameter set to a directory, cd to it
setopt CORRECT              # Try to correct minor misspellings of commands
# setopt CORRECT_ALL          # Try to correct commands and arguments
setopt EXTENDED_GLOB        # Enable more advanced globbing features (e.g., ^ for negation, # for recursion)
setopt GLOB_DOTS            # Include dotfiles in globbing results (e.g., * will match .file)
setopt NUMERIC_GLOB_SORT    # Sort filenames numerically when globbing (e.g., 1, 2, 10 instead of 1, 10, 2)
setopt RC_QUOTES            # Allow 'val''ue' to be val'ue
setopt MAIL_WARNING         # Warn if mail file has been accessed since last check
setopt PROMPT_SUBST         # Allow parameter expansion, command substitution in prompts (Starship handles its own, but good for custom prompts)
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell (e.g. echo foo # this is a comment)
# --- End Useful Zsh Options (setopt) ---



# autosuggest
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#bac2de,underline"
if [ -f "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
else
  echo "ERROR: zsh-autosuggestions (installed via pacman) not found at /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# --- Loading zsh-syntax-highlighting (pacman version) ---
# This must be sourced BEFORE its theme (Catppuccin).
if [ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
  echo "ERROR: zsh-syntax-highlighting (installed via pacman) not found at /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# --- Loading Catppuccin theme for zsh-syntax-highlighting ---
# in ~/.zsh
if [ -f "$HOME/.zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh" ]; then
  # Define Catppuccin flavour for syntax highlighting
  export ZSH_HIGHLIGHT_CATPPUCCIN_FLAVOUR="macchiato"
  source "$HOME/.zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh"
else
  echo "ERROR: Catppuccin theme for zsh-syntax-highlighting not found at $HOME/.zsh/catppuccin_macchiato-zsh-syntax-highlighting.zsh"
fi

# Starship init
eval "$(starship init zsh)"