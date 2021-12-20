# --- path 

# --- zsh theme 
ZSH_THEME="af-magic"
COMPLETION_WAITING_DOTS="true"
DISABLE_AUTO_UPDATE="false"
ENABLE_CORRECTION="true"
ZSH_DISABLE_COMPFIX="true"

# --- iterm matplotlib backend 
# export MPLBACKEND="module://itermplot"
# export ITERMPLOT=rv

# --- zsh plugins 
plugins=(git vi-mode python)

# export ZSH="""
export LANG=en_US.UTF-8
# export ARCHFLAGS="-arch x86_64"

# --- aliases 
alias python="python3"

# --- configrations 
alias zshconfig="nvim ~/.zshrc"
alias nvimconfig="nvim ~/.config/nvim/init.vim"

# --- one liners 
alias ppath="echo $PATH | tr ':' '\n'"
alias disassemble="otool -tv"
alias xclip="xclip -selection c"
alias getclip="xclip -selection c -o"

# --- resources 
alias ascii="cat /usr/share/misc/ascii"

# --- useful functions 
pip_grep () { pip list | grep $1 }

mcd () { mkdir $1; cd $1 }

autoload mcd 

source $ZSH/oh-my-zsh.sh
