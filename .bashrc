#!/usr/bin/env bash

# Check if shell is interactive
iatest=$(expr index "$-" i)

#######################################################
# SYSTEM INITIALIZATION
#######################################################

# Display system info on interactive shell startup
if command -v fastfetch &>/dev/null; then
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
shopt -s checkwinsize       # Update window size variables
shopt -s histappend         # Append to history instead of overwriting
PROMPT_COMMAND='history -a' # Save history immediately

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
export EDITOR=nvim
export VISUAL=nvim
export PATH=$PATH:~/opt/zig

# MODERN TOOL REPLACEMENTS
#######################################################

if command -v fd &>/dev/null; then
    alias find='fd'
elif command -v fd-find &>/dev/null; then
    alias find='fd-find'
fi

alias grep='rg'
alias ls='eza -a --color=auto --group-directories-first --git --icons'
alias ll='eza -la --color=auto --group-directories-first --git --icons'

if command -v batcat &>/dev/null; then
    alias cat='batcat --style=auto'
elif command -v bat &>/dev/null; then
    alias cat='bat --style=auto'
fi

#######################################################
# SAFETY ALIASES
#######################################################

alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v' # Use trash-cli for recoverable deletion

#######################################################
# ENHANCED BASIC COMMANDS
#######################################################

# Better defaults for common commands
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias less='less -R'
alias multitail='multitail --no-repeat -c'
alias rmd='/bin/rm --recursive --force --verbose'

# Editor aliases
alias vim='nvim'
alias vi='nvim'
alias svi='sudo nvim'
alias vis='nvim "+set si"'

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
alias vbrcl="nvim ~/.bashrc_local"
alias sbrc="source ~/.bashrc"
alias xdg="xdg-open"
alias qt="quiet"
alias h="history | grep " # history search
alias p="ps aux | grep "  # process search
alias f="find . | grep "  # file search
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias openports='netstat -nape --inet'
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias checkcommand="type -t"
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'
alias hibernate='sudo systemctl hibernate'
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
alias tm='tmux attach -t default 2>/dev/null || tmux new -s default'

#######################################################
# CUSTOM FUNCTIONS
#######################################################

# Run command quietly in background
quiet() {
    "$@" &>/dev/null &
}

# Automatically do an ls after each cd, z, or zoxide
cd() {
    if [ -n "$1" ]; then
        builtin cd "$@" && ls
    else
        builtin cd ~ && ls
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
    grep -iIHrn --color=always "$1" .
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
            *.tar.bz2 | *.tbz2) tar xvjf "$archive" ;;
            *.tar.gz | *.tgz) tar xvzf "$archive" ;;
            *.bz2) bunzip2 "$archive" ;;
            *.rar) rar x "$archive" ;;
            *.gz) gunzip "$archive" ;;
            *.tar) tar xvf "$archive" ;;
            *.zip) unzip "$archive" ;;
            *.Z) uncompress "$archive" ;;
            *.7z) 7z x "$archive" ;;
            *) echo "Don't know how to extract '$archive'" ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Detailed ls
lsc() {
    eza -la --color=auto --group-directories-first --git --icons --bytes --time-style=long-iso "$@"
    echo
    file_count=$(find . -maxdepth 1 -type f | wc -l)
    dir_count=$(find . -maxdepth 1 -type d ! -name '.' | wc -l)
    total_size=$(du -sh . 2>/dev/null | cut -f1)
    echo "Files: $file_count  Dirs: $dir_count  Size: $total_size"
}

# Get current clipboard
clip() {
    if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-paste &>/dev/null; then
        wl-paste
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard -o
    else
        echo "No working clipboard utility found" >&2
        return 1
    fi
}

# Compile cpp executable
gcpp() {
    if [ $# -eq 0 ]; then
        echo "Usage: gccpp <main.cpp|main.o> [additional files...] [flags...]"
        echo "Example: gccpp main.cpp utils.cpp math.hpp -lm -pthread"
        echo "Example: gccpp main.o utils.o -lm -pthread"
        return 1
    fi
    local first_file="$1"
    local output
    # Remove both .cpp and .o extensions for output name
    if [[ "$first_file" == *.cpp ]]; then
        output="${first_file%.cpp}"
    elif [[ "$first_file" == *.cxx ]]; then
        output="${first_file%.cxx}"
    elif [[ "$first_file" == *.cc ]]; then
        output="${first_file%.cc}"
    elif [[ "$first_file" == *.C ]]; then
        output="${first_file%.C}"
    elif [[ "$first_file" == *.o ]]; then
        output="${first_file%.o}"
    else
        output="$first_file" # fallback for other extensions
    fi
    g++ -Wall -Wextra -Wshadow -Werror -pedantic -std=c++20 -g "$@" -lsyleec -o "$output"
}

# Compile cpp object files
gcppo() {
    if [ $# -eq 0 ]; then
        echo "Usage: gcppo <main.cpp> [additional files...] [flags...]"
        echo "Example: gcppo main.cpp utils.cpp math.hpp -lm -pthread"
        return 1
    fi
    local first_file="$1"
    local output
    # Handle different C++ extensions for object file output
    if [[ "$first_file" == *.cpp ]]; then
        output="${first_file%.cpp}.o"
    elif [[ "$first_file" == *.cxx ]]; then
        output="${first_file%.cxx}.o"
    elif [[ "$first_file" == *.cc ]]; then
        output="${first_file%.cc}.o"
    elif [[ "$first_file" == *.C ]]; then
        output="${first_file%.C}.o"
    else
        output="${first_file}.o" # fallback
    fi
    g++ -Wall -Wextra -Wshadow -Werror -pedantic -std=c++20 -g -c "$@" -lsyleec -o "$output"
}

# Compile c executable
gc() {
    if [ $# -eq 0 ]; then
        echo "Usage: gcce <main.c|main.o> [additional files...] [flags...]"
        echo "Example: gcce main.c utils.c math.h -lm -pthread"
        echo "Example: gcce main.o utils.o -lm -pthread"
        return 1
    fi

    local first_file="$1"
    local output

    # Remove both .c and .o extensions for output name
    if [[ "$first_file" == *.c ]]; then
        output="${first_file%.c}"
    elif [[ "$first_file" == *.o ]]; then
        output="${first_file%.o}"
    else
        output="$first_file" # fallback for other extensions
    fi

    gcc -Wall -Wextra -Wshadow -Werror -pedantic -std=c17 -g "$@" -lsyleec -o "$output"
}

# Compile c object files
gco() {
    if [ $# -eq 0 ]; then
        echo "Usage: gcco <main.c> [additional files...] [flags...]"
        echo "Example: gcco main.c utils.c math.h -lm -pthread"
        return 1
    fi
    local first_file="$1"
    local output="${first_file%.c}.o"
    gcc -Wall -Wextra -Wshadow -Werror -pedantic -std=c17 -g -c "$@" -lsyleec -o "$output"
}

# Easy benchmark function
bench() {
    local warmup=3
    local runs=10

    # Parse custom options
    while [[ $1 == -* ]]; do
        case $1 in
        -w | --warmup)
            warmup="$2"
            shift 2
            ;;
        -r | --runs)
            runs="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            return 1
            ;;
        esac
    done

    hyperfine --warmup "$warmup" --runs "$runs" "$*"
}

# Compare two versions
compare() {
    hyperfine --warmup 3 --runs 10 "$1" "$2"
}

# Windows config sync functions
function pull_powershell() {
    if [ -z "$WINDOWS_POWERSHELL_PROFILE" ]; then
        echo "Error: WINDOWS_POWERSHELL_PROFILE not set in .bashrc_local"
        return 1
    fi

    mkdir -p ~/.config/windows
    if [ -f "$WINDOWS_POWERSHELL_PROFILE" ]; then
        cp "$WINDOWS_POWERSHELL_PROFILE" ~/.config/windows/powershell_profile.ps1
        echo "PowerShell profile pulled from Windows to WSL"
    else
        echo "Warning: PowerShell profile not found at $WINDOWS_POWERSHELL_PROFILE"
    fi
}

function push_powershell() {
    if [ -z "$WINDOWS_POWERSHELL_PROFILE" ]; then
        echo "Error: WINDOWS_POWERSHELL_PROFILE not set in .bashrc_local"
        return 1
    fi

    if [ -f ~/.config/windows/powershell_profile.ps1 ]; then
        mkdir -p "$(dirname "$WINDOWS_POWERSHELL_PROFILE")"
        cp ~/.config/windows/powershell_profile.ps1 "$WINDOWS_POWERSHELL_PROFILE"
        echo "PowerShell profile pushed from WSL to Windows"
    else
        echo "Error: ~/.config/windows/powershell_profile.ps1 not found"
    fi
}

function pull_terminal() {
    if [ -z "$WINDOWS_TERMINAL_SETTINGS" ]; then
        echo "Error: WINDOWS_TERMINAL_SETTINGS not set in .bashrc_local"
        return 1
    fi

    mkdir -p ~/.config/windows
    if [ -f "$WINDOWS_TERMINAL_SETTINGS" ]; then
        cp "$WINDOWS_TERMINAL_SETTINGS" ~/.config/windows/terminal_settings.json
        echo "Terminal settings pulled from Windows to WSL"
    else
        echo "Warning: Terminal settings not found at $WINDOWS_TERMINAL_SETTINGS"
    fi
}

function push_terminal() {
    if [ -z "$WINDOWS_TERMINAL_SETTINGS" ]; then
        echo "Error: WINDOWS_TERMINAL_SETTINGS not set in .bashrc_local"
        return 1
    fi

    if [ -f ~/.config/windows/terminal_settings.json ]; then
        mkdir -p "$(dirname "$WINDOWS_TERMINAL_SETTINGS")"
        cp ~/.config/windows/terminal_settings.json "$WINDOWS_TERMINAL_SETTINGS"
        echo "Terminal settings pushed from WSL to Windows"
    else
        echo "Error: ~/.config/windows/terminal_settings.json not found"
    fi
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

if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi

#######################################################
# ADDITIONAL USEFUL FEATURES FROM DEFAULT UBUNTU/POP!_OS
#######################################################

# Enable globstar for recursive directory matching with **
# This allows patterns like "**/*.rs" to match files recursively
shopt -s globstar

# Make less more friendly for non-text input files (works on both Ubuntu and Pop!_OS)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot environment (useful for containers and WSL)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Colored GCC warnings and errors (useful for C/C++/Rust development)
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Enable color support for more commands if dircolors is available
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Alert alias for long running commands - cross-platform notification
# Usage: long_command; alert
# Works with both native Linux notifications and WSL (if Windows notifications are set up)
if command -v notify-send &>/dev/null; then
    # Native Linux (Pop!_OS, Ubuntu desktop)
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '"'"'s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'"'"')"'
elif [[ -n "${WSL_DISTRO_NAME:-}" ]] && command -v powershell.exe &>/dev/null; then
    # WSL with Windows PowerShell available
    alias alert='powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(\"Command finished: $(history|tail -n1|sed -e '"'"'s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'"'"')\", \"Terminal Alert\")"'
else
    # Fallback: just echo (works everywhere)
    alias alert='echo "Alert: $(history|tail -n1|sed -e '"'"'s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'"'"') - Command finished"'
fi

# Set terminal title to show current directory (works in most terminals including WSL)
case "$TERM" in
xterm* | rxvt* | alacritty* | screen* | tmux*)
    # Update terminal title with user@host:directory
    # This works in both native Linux and WSL terminals
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
*) ;;
esac

#######################################################
# TOOL INITIALIZATION
#######################################################

# Starship
if command -v starship &>/dev/null; then
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
