# Git Bash configuration for FPGA development
# Enhanced with ZSH-like features

# Load system bash completion if available
for completion_file in \
    /usr/share/bash-completion/bash_completion \
    /etc/bash_completion \
    /mingw64/share/bash-completion/bash_completion; do
    if [[ -f "$completion_file" ]]; then
        source "$completion_file"
        break
    fi
done

# Load project-specific completions
if [ -f .bash_completion ]; then
    source .bash_completion
fi

# ZSH-like completion behavior
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set menu-complete-display-prefix on'
bind 'set colored-completion-prefix on'
bind 'set completion-map-case on'
bind 'set skip-completed-text on'
bind 'set print-completions-horizontally off'
bind 'set page-completions off'
bind 'set completion-query-items 50'

# Make Tab and Shift+Tab cycle through completions like zsh
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

# Enhanced history like zsh
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups:ignorespace
export HISTTIMEFORMAT='%F %T '
shopt -s histappend
shopt -s histverify
shopt -s checkwinsize
shopt -s autocd 2>/dev/null || true  # cd by typing directory name

# ZSH-like history search
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

# Better Ctrl+R
bind '"\C-r": reverse-search-history'

# ZSH-like directory shortcuts
setopt() { :; }  # Ignore zsh setopt commands
# alias -='cd -'  # This doesn't work in bash, commenting out
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Enhanced cd that shows directory contents
cd() {
    if builtin cd "$@"; then
        # Show directory contents after cd (like zsh AUTO_LS)
        if [[ $(ls -1A | wc -l) -le 20 ]]; then
            ls --color=auto -la
        else
            echo "📁 $(ls -1A | wc -l) items in $(pwd)"
            ls --color=auto -la | head -10
            echo "... and $(( $(ls -1A | wc -l) - 10 )) more items"
        fi
        
        # Show git status if in git repo
        if [[ -d .git ]]; then
            echo ""
            echo "🐙 Git: $(git branch --show-current 2>/dev/null || echo 'detached')"
            local git_status=$(git status --porcelain 2>/dev/null)
            if [[ -n "$git_status" ]]; then
                echo "📊 Changes: $(echo "$git_status" | wc -l) files modified"
            else
                echo "✅ Working tree clean"
            fi
        fi
        
        # Show make targets if Makefile exists
        if [[ -f Makefile ]] && [[ $(pwd) == *"6502_fpga"* ]]; then
            echo ""
            echo "🔨 Make targets available (type 'targets' to see all)"
        fi
    fi
}

# FPGA development aliases (enhanced)
alias m='make'
alias targets='list_make_targets'
alias bp='make build-and-program'
alias sw='make simulate-and-wave'

# Quick simulation shortcuts
alias sim1='make run-sim-tutorial-step1'
alias sim2='make run-sim-tutorial-step2'
alias sim3='make run-sim-tutorial-step3'
alias sim4='make run-sim-tutorial-step4'

# Quick waveform shortcuts  
alias wave1='make wave-tutorial-step1'
alias wave2='make wave-tutorial-step2'
alias wave3='make wave-tutorial-step3'
alias wave4='make wave-tutorial-step4'

# Enhanced ls with colors and better defaults
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
    alias lt='ls -altr --color=auto'  # Sort by time
    alias lh='ls -alh --color=auto'   # Human readable sizes
else
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias lt='ls -altr'
    alias lh='ls -alh'
fi

# Enhanced grep with colors and useful options
alias grep='grep --color=auto -n'
alias fgrep='fgrep --color=auto -n'
alias egrep='egrep --color=auto -n'
alias rgrep='grep -r --color=auto -n'

# Git shortcuts with better formatting (ZSH-like)
alias gs='git status -sb'  # Short format with branch
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --color=always'
alias gd='git diff --color=always'
alias gdc='git diff --color=always --cached'
alias gb='git branch -v --color=always'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias gsp='git stash pop'

# File operations with safety
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# Better file viewing
alias cat='cat -n'
alias less='less -R'  # Handle colors
alias more='less -R'
alias h='history | tail -20'
alias hg='history | grep'

# Process and system info
alias psg='ps aux | grep -v grep | grep'
alias j='jobs'
alias k='kill'
alias pk='pkill'

# Network (limited in Git Bash but still useful)
alias ping='ping -c 4'

# Development helpers
alias py='python'
alias py3='python3'
alias pip='python -m pip'
alias serve='python -m http.server 8000'
alias json='python -m json.tool'

# Text editing shortcuts
alias nano='nano -c'  # Show line numbers
alias vi='vim'

# Quick directory operations
alias md='mkdir'
alias rd='rmdir'

# Show disk usage
alias du='du -h'
alias df='df -h'

# Simple, reliable prompt with git branch
git_info() {
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        echo "($branch)"
    fi
}

# Clean, simple prompt without git info to avoid errors
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\[\033[01;36m\]❯\[\033[00m\] '

# Manual git info function (call with 'git_info' command)
git_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "🐙 Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
        local status=$(git status --porcelain 2>/dev/null)
        if [[ -n "$status" ]]; then
            echo "📊 Status: $(echo "$status" | wc -l) changes"
        else
            echo "✅ Status: clean"
        fi
    else
        echo "❌ Not in a git repository"
    fi
}

# Functions for better development workflow (ZSH-like)
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Enhanced find functions
ff() {
    find . -name "*$1*" -type f 2>/dev/null
}

fd() {
    find . -name "*$1*" -type d 2>/dev/null
}

# Grep in source files
gf() {
    grep -r "$1" . --include="*.v" --include="*.sv" --include="*.vhd" --include="*.c" --include="*.h" --include="*.py" --color=always -n
}

# Show file tree (if tree is available, otherwise use ls)
tree() {
    if command -v /usr/bin/tree >/dev/null; then
        /usr/bin/tree "$@"
    else
        find "${1:-.}" -type d | head -20 | sed 's/[^-][^\/]*\//  |/g; s/|/├/; s/  ├/├/'
    fi
}

# Quick context information (ZSH-like)
show_context() {
    echo ""
    echo "📍 $(pwd)"
    echo "📁 $(ls -1A | wc -l) items"
    if [[ -d .git ]]; then
        echo "� $(git branch --show-current 2>/dev/null || echo 'detached HEAD')"
        local changes=$(git status --porcelain 2>/dev/null | wc -l)
        echo "📊 $changes changes"
    fi
    if [[ -f Makefile ]]; then
        local targets=$(make -qp 2>/dev/null | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A){if(A[i] ~ /^[a-zA-Z0-9_-]+$/ && A[i] !~ /Makefile/) print A[i]}}' | wc -l)
        echo "🔨 $targets make targets"
    fi
    echo ""
}

# Auto-run show_context when opening new terminal in project directory
if [[ $(pwd) == *"6502_fpga"* ]]; then
    show_context
fi

echo "🚀 ZSH-like Enhanced Git Bash loaded!"
echo "   ⌨️  Tab completion: Enhanced with descriptions and cycling"
echo "   📁 Auto-ls: Directory contents shown after cd"
echo "   🎯 Try: make <Tab> | git <Tab> | show_context"
echo "   💡 Arrow keys search history | Ctrl+R for reverse search"
