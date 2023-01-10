# greeting
set fish_greeting '\n持续思考，保持清醒。'

# thefuck
# eval "$(thefuck --alias)"

# save my life
# alias rm=trash

# autojump
# . /opt/homebrew/share/autojump/autojump.fish

# shell
set -x SHROOT ~/script/sh
set -x SCRIPTROOT ~/script
set -x PATH $SHROOT:$PATH

# proxy
set -x https_proxy http://127.0.0.1:7890
set -x http_proxy http://127.0.0.1:7890 
set -x all_proxy socks5://127.0.0.1:7890

# chinese display problems after vscodev1.74.0 is updated
# set -x LANG zh_CN.UTF-8 # still propblems in vim
set -x LANG


# short git
alias gs="git status -s"
alias ga="git add"
alias gc="git commit -m"
alias gp="git pull --rebase"
alias gps="git push"
alias gpsf="git push -f"
function gri
  git rebase -i HEAD~$argv;
end
alias gr="git rebase"
alias gsc="git lg -S"
alias gsm="git lg --grep"
alias gus="git restore --staged"
alias guw="git restore"
