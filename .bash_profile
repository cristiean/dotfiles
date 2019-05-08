# name@computer_name:current_path$ 
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "

# current_path$ 
#export PS1="\[\033[33;1m\]\w\[\033[m\]\$ "

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export PATH="$HOME/.cargo/bin:$PATH"

# -G Enables colorised output, -F Displays different symbols with ls, -h Reduces the number of digits for sizes
alias ls='ls -GFh'

# easier to open documents with MacVim
alias vimm='open -a MacVim $1'
