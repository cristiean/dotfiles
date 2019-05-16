### Set Prompt Script to: name@computer_name:current_path$ #######################
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
##################################################################################

### Set Prompt Script to: current_path$ ##########################################
# export PS1="\[\033[33;1m\]\w\[\033[m\]\$ "
##################################################################################

### Colorise the terminal ########################################################
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
##################################################################################

### Improve 'ls' #################################################################
# -G Enables colorised output
# -F Displays different symbols for the different files/directories
alias ls="ls -GF"
##################################################################################

### Open files with MacVim #######################################################
alias vimm="open -a MacVim $1"
##################################################################################

### Weather ######################################################################
weather(){
    curl http://wttr.in/"$1"                        # Use: $ weather City
}    
##################################################################################

### Git ##########################################################################
clone(){
    git clone https://github.com/"$1"               # Use: $ clone username/repo
}
alias checkout='git checkout'
alias status="git status"
alias branch="git branch"
alias commit="git commit"
alias pull="git pull"
alias push="git push"
alias add="git add"
##################################################################################

### Change Directory shortcuts ###################################################
alias desktop="cd ~/Desktop"
alias root="cd ~/"
##################################################################################

### Experimental #################################################################
cdfind(){
    cd $(find "$1" -name "$2")                      # Use: cdfind /Documents notes
}
alias ..="cd .."
##################################################################################
