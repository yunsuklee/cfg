#!/usr/bin/env bash

# Check if shell is interactive
iatest=$(expr index "$-" i)

#######################################################
# SYSTEM INITIALIZATION
#######################################################

# Display system info on interactive shell startup
if command -v fastfetch &> /dev/null; then
    if [[ $- == *i* ]]; then
        fastfetch
    fi
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Enable bash programmable completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#######################################################
# SHELL BEHAVIOR CONFIGURATION
#######################################################

# Disable annoying bell, use visual instead
if [[ $iatest -gt 0 ]]; then 
    bind "set bell-style visible"
fi
set bell-style none

# History configuration
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Better terminal behavior
shopt -s checkwinsize    # Update window size variables
shopt -s histappend      # Append to history instead of overwriting
PROMPT_COMMAND='history -a'  # Save history immediately

# Allow Ctrl+S for forward history search
[[ $- == *i* ]] && stty -ixon

# Enhanced auto-completion
if [[ $iatest -gt 0 ]]; then
    bind "set completion-ignore-case on"
    bind "set show-all-if-ambiguous On"
fi

#######################################################
# ENVIRONMENT VARIABLES
#######################################################

export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Default editors
export EDITOR=nvim
export VISUAL=nvim

#######################################################
# MODERN TOOL REPLACEMENTS
#######################################################

alias find='fd'
alias grep='rg'
alias ls='eza -a --color=auto --group-directories-first'
alias ll='eza -la --color=auto --group-directories-first'

if command -v batcat &> /dev/null; then
    alias cat='batcat --style=auto'
elif command -v bat &> /dev/null; then
    alias cat='bat --style=auto'
fi

#######################################################
# SAFETY ALIASES
#######################################################

# Interactive/safe versions of destructive commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'  # Use trash-cli for recoverable deletion

#######################################################
# ENHANCED BASIC COMMANDS
#######################################################

# Better defaults for common commands
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias less='less -R'
alias multitail='multitail --no-repeat -c'
alias rmd='/bin/rm --recursive --force --verbose'
alias freshclam='sudo freshclam'

# Editor aliases
alias vim='nvim'
alias vi='nvim'
alias svi='sudo nvim'
alias vis='nvim "+set si"'
alias lv='NVIM_APPNAME=nvim-lazyvim nvim'

#######################################################
# NAVIGATION ALIASES
#######################################################

# Directory navigation
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

#######################################################
# PRODUCTIVITY ALIASES
#######################################################

alias cfg='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias cl="clear"
alias vbrc="nvim ~/.bashrc"
alias vbrcl="nvim ~/.bashrc.local"
alias sbrc="source ~/.bashrc"
alias xdg="xdg-open"
alias qt="quiet"
alias h="history | grep " # history search
alias p="ps aux | grep " # process search
alias f="find . | grep " # file search
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias openports='netstat -nape --inet'
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias checkcommand="type -t"
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
alias upall='update_all'

#######################################################
# CUSTOM FUNCTIONS
#######################################################

# Run command quietly in background
quiet() {
    "$@" &> /dev/null &
}

# Enhanced cd with automatic ls
cd() {
    if [ $# -eq 0 ]; then
        # No arguments, go to home (like original cd)
        builtin cd
    elif [ -d "$1" ]; then
        # If it's a valid directory, use original cd
        builtin cd "$1"
    else
        # Otherwise, try zoxide
        z "$1"
    fi
}

# Create directory and enter it
mkdirg() {
    if [ -z "$1" ]; then
        echo "Usage: mkdirg <directory_path>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Copy and go to destination (if directory)
cpg() {
    if [ $# -ne 2 ]; then
        echo "Usage: cpg <source> <destination>"
        return 1
    fi
    if [ -d "$2" ]; then
        cp -r "$1" "$2" && cd "$2"
    else
        cp -r "$1" "$2"
    fi
}

# Move and go to destination (if directory)
mvg() {
    if [ $# -ne 2 ]; then
        echo "Usage: mvg <source> <destination>"
        return 1
    fi
    if [ -d "$2" ]; then
        mv "$1" "$2" && cd "$2"
    else
        mv "$1" "$2"
    fi
}

# Search for text in files
ftext() {
    if [ -z "$1" ]; then
        echo "Usage: ftext <search_term>"
        return 1
    fi
    grep -iIHrn --color=always "$1" . | less -r
}

# Get last 2 directories from current path
pwdtail() {
    pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Universal archive extractor
extract() {
    if [ $# -eq 0 ]; then
        echo "Usage: extract <archive_file(s)>"
        return 1
    fi

    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case $archive in
                *.tar.bz2|*.tbz2)   tar xvjf "$archive" ;;
                *.tar.gz|*.tgz)     tar xvzf "$archive" ;;
                *.bz2)              bunzip2 "$archive" ;;
                *.rar)              rar x "$archive" ;;
                *.gz)               gunzip "$archive" ;;
                *.tar)              tar xvf "$archive" ;;
                *.zip)              unzip "$archive" ;;
                *.Z)                uncompress "$archive" ;;
                *.7z)               7z x "$archive" ;;
                *)                  echo "Don't know how to extract '$archive'" ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Universal system update function
update_all() {
    echo "🚀 Starting system-wide updates..."
    echo "=================================="
    
    # DNF updates
    echo "📦 Updating DNF packages..."
    sudo dnf upgrade --refresh -y
    
    # Clean DNF cache
    echo "🧹 Cleaning DNF cache..."
    sudo dnf clean all
    
    # Flatpak updates  
    echo "📱 Updating Flatpak applications..."
    flatpak update -y
    
    # Clean Flatpak cache
    echo "🧹 Cleaning Flatpak cache..."
    flatpak uninstall --unused -y
    
    # Cargo updates (if you have cargo-update installed)
    if command -v cargo-install-update &> /dev/null; then
        echo "🦀 Updating Rust packages..."
        cargo install-update -a
    fi
    
    # Update fastfetch (system info tool)
    if command -v fastfetch &> /dev/null; then
        echo "💻 System info after updates:"
        fastfetch
    fi
    
    echo "✅ All updates completed!"
    echo "🔄 Consider rebooting if kernel was updated."
}

#######################################################
# AUTO-START X SESSION
#######################################################

# Auto-start DWM on TTY1 if configured
if [[ "$(tty)" == "/dev/tty1" ]] && [ -f "$HOME/.xinitrc" ] && grep -q "^exec dwm" "$HOME/.xinitrc"; then
    startx
fi

#######################################################
# IMPORT MACHINE SPECIFIC CONFIGURATION 
#######################################################

if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

#######################################################
# TOOL INITIALIZATION
#######################################################

# Starship
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# Source Rust environment
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Zoxide keybinding - Ctrl+f for interactive directory picker
if [[ $- == *i* ]]; then
    bind '"\C-f":"zi\n"'
fi

# Initialize modern shell tools
eval "$(zoxide init bash)"
