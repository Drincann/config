# autojump
[ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish

# save my life
alias rm=trash

# greetings
set -x fish_greeting "TODO:\n$(todo)"

# chinese display problems after vscodev1.74.0 is updated
# set -x LANG zh_CN.UTF-8 # still propblems in vim
set -x LANG

# proxy
set -x https_proxy http://127.0.0.1:7890
set -x http_proxy http://127.0.0.1:7890
set -x all_proxy socks5://127.0.0.1:7890

# script
set -x SHROOT /Users/drincanngao/script/sh
set -x SCRIPTROOT /Users/drincanngao/script
set -x PATH $SHROOT:$PATH

# fish reload
alias fr "source ~/.config/fish/config.fish"

# git alias
alias g git

# git status
# usage:
# gs [options] —— git status -[options]
function gs
    if test -z "$argv"
        echo "git status"
        git status
    else
        echo "git status -$argv"
        git status -$argv
    end
end
alias gss "gs s"

# git add 
alias ga "git add"
alias gap "git add -p"

# git commit 
# usage: 
# gc                  —— git commit 
# gc "commit message" —— git commit -m "commit message"
function gc
    if test -z "$argv"
        echo "git commit"
        git commit
    else
        echo "git commit -m $argv"
        git commit -m "$argv"
    end
end

# git push/pull
alias gpl "git pull --rebase"
alias gps "git push"

# git rebase
# usage:
# gri [number] —— git rebase -i HEAD~[number]
# gri [hash]   —— git rebase -i [hash]
function gri
    # if length of $argv is less eq than 7 and $argv is a number 
    if test (echo $argv | wc -c) -le 7 -a (echo $argv | grep -E '^[0-9]+$')
        echo "git rebase -i HEAD~$argv"
        git rebase -i HEAD~$argv
    else
        echo "git rebase -i $argv"
        git rebase -i $argv
    end
end
alias gr "git rebase"

# git checkout
alias gco "git checkout"
alias gcom "git checkout master"

# git branch
alias gb "git checkout -b"
alias gbd "git branch -d"

# git lg
alias lg "git lg"
alias gl "git lg"

# git search
alias gsc "git lg -S" # search by file content
alias gsm "git lg --grep" # search by commit message

# git restore
alias gust "git restore --staged"
alias guwk "git restore"

# git reset
# usage:
# grs [f] [number] —— git reset --[:soft|f:hard] HEAD~[number]
# grs [f] [hash]   —— git reset --[:soft|f:hard] [hash]
# example:
# grs —— git reset --soft HEAD^
function grs
    set softOrHard soft
    set ref HEAD^
    if not test (count $argv) -eq 0
        if test $argv[1] = f
            set softOrHard hard
            if not test -z $argv[2]
                if test (echo $argv[2] | wc -c) -le 7 -a (echo $argv[2] | grep -E '^[0-9]+$')
                    set ref HEAD~$argv[2]
                else
                    set ref $argv[2]
                end
            end
        else
            if test (echo $argv[1] | wc -c) -le 7 -a (echo $argv[1] | grep -E '^[0-9]+$')
                set ref HEAD~$argv[1]
            else
                set ref $argv[1]
            end
        end
    end
    echo "git reset --$softOrHard $ref"
    git reset --$softOrHard $ref
end

# soft or hard reset to any ref
# usage:
# gsinc [f] [upstream] [branch] —— git reset --[:soft|:f:hard] [upstream:upstream|:default upstream]/[branch:branch|:current branch]
# example:
# gsinc f upstream —— git reset --hard upstream/currbranch
# gsinc upstream   —— git reset --soft master
# gsinc          —— git reset --soft upstream/currbranch
# gsinc f        —— git reset --hard upstream/currbranch 
function gsinc
    set softOrHard soft
    set upstream origin
    set branch (git branch --show-current)

    if not test (count $argv) -eq 0
        if test $argv[1] = f
            set softOrHard hard
            if not test -z $argv[2]
                set upstream $argv[2]
                if not test -z $argv[3]
                    set branch $argv[3]
                end
            end
        else
            set upstream $argv[1]
            if not test -z $argv[2]
                set branch $argv[2]
            end
        end
    end

    echo "git reset --$softOrHard $upstream/$branch"
    git reset --$softOrHard $upstream/$branch
end
