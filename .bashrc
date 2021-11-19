#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -f ~/.welcome_screen ]] && . ~/.welcome_screen

_set_my_PS1() {
    PS1='[\u@\h \W]\$ '
    if [ "$(whoami)" = "liveuser" ] ; then
        local iso_version="$(grep ^VERSION= /usr/lib/endeavouros-release 2>/dev/null | cut -d '=' -f 2)"
        if [ -n "$iso_version" ] ; then
            local prefix="eos-"
            local iso_info="$prefix$iso_version"
            PS1="[\u@$iso_info \W]\$ "
        fi
    fi
}
_set_my_PS1
unset -f _set_my_PS1

ShowInstallerIsoInfo() {
    local file=/usr/lib/endeavouros-release
    if [ -r $file ] ; then
        cat $file
    else
        echo "Sorry, installer ISO info is not available." >&2
    fi
}



[[ "$(whoami)" = "root" ]] && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

################################################################################
## Some generally useful functions.
## Consider uncommenting liases below to start using these functions.


_GeneralCmdCheck() {
    # A helper for functions UpdateArchPackages and UpdateAURPackages.

    echo "$@" >&2
    "$@" || {
        echo "Error: '$*' failed." >&2
        exit 1
    }
}

_CheckInternetConnection() {
    # curl --silent --connect-timeout 8 https://8.8.8.8 >/dev/null
    eos-connection-checker
    local result=$?
    test $result -eq 0 || echo "No internet connection!" >&2
    return $result
}

_CheckArchNews() {
    local conf=/etc/eos-update-notifier.conf

    if [ -z "$CheckArchNewsForYou" ] && [ -r $conf ] ; then
        source $conf
    fi

    if [ "$CheckArchNewsForYou" = "yes" ] ; then
        local news="$(paru -Pw)"
        if [ -n "$news" ] ; then
            echo "Arch news:" >&2
            echo "$news" >&2
            echo "" >&2
            # read -p "Press ENTER to continue (or Ctrl-C to stop): "
        else
            echo "No Arch news." >&2
        fi
    fi
}

UpdateArchPackages() {
    # Updates Arch packages.

    _CheckInternetConnection || return 1

    _CheckArchNews

    #local updates="$(yay -Qu --repo)"
    local updates="$(checkupdates)"
    if [ -n "$updates" ] ; then
        echo "Updates from upstream:" >&2
        echo "$updates" | sed 's|^|    |' >&2
        _GeneralCmdCheck sudo pacman -Syu "$@"
        return 0
    else
        echo "No upstream updates." >&2
        return 1
    fi
}

UpdateAURPackages() {
    # Updates AUR packages.

    _CheckInternetConnection || return 1

    local updates
    if [ -x /usr/bin/yay ] ; then
        updates="$(yay -Qua)"
        if [ -n "$updates" ] ; then
            echo "Updates from AUR:" >&2
            echo "$updates" | sed 's|^|    |' >&2
            _GeneralCmdCheck yay -Syua "$@"
        else
            echo "No AUR updates." >&2
        fi
    else
        echo "Warning: /usr/bin/yay does not exist." >&2
    fi
}

UpdateAllPackages() {
    # Updates all packages in the system.
    # Upstream (i.e. Arch) packages are updated first.
    # If there are Arch updates, you should run
    # this function a second time to update
    # the AUR packages too.

    UpdateArchPackages || UpdateAURPackages
}


_open_files_for_editing() {
    # Open any given document file(s) for editing (or just viewing).
    # Note1: Do not use for executable files!
    # Note2: uses mime bindings, so you may need to use
    #        e.g. a file manager to make some file bindings.

    local progs="xdg-open exo-open"     # One of these programs is used.
    local prog
    for prog in $progs ; do
        if [ -x /usr/bin/$xx ] ; then
            $prog "$@" >& /dev/null &
            return
        fi
    done
    echo "Sorry, none of programs [$progs] is found." >&2
    echo "Tip: install one of packages" >&2
    for prog in $progs ; do
        echo "    $(pacman -Qqo "$prog")" >&2
    done
}

# aliasses

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?*'   # show long listing but no hidden dotfiles except "."
alias v='nvim'
alias vim='nvim'
alias t='todo.sh'
alias suvi='sudo nvim'
alias tsc='sudo timeshift --create'
alias Syu='tsc && yay -Syu'
alias vpoly='nvim ~/.config/polybar/config'
alias vpolymod='nvim ~/.config/polybar/modules.ini'
alias vi3='nvim ~/.config/i3/config'
alias notes='nvim ~/MEGA/Notes/notes.txt'
alias films='xdg-open https://tinyurl.com/yb7m3454'
alias rds='cd /home/omk/MEGA/Documents\ M/Ruidos/Site\ Ruidos/'
alias rdsep='cd /home/omk/MEGA/Documents\ M/Ruidos/Site\ Ruidos/ && nvim Ep00\ Template.html'
alias vconf='nvim /home/omk/.config/nvim/init.vim'
alias copy='xclip -selection clipboard'
alias paste='xclip -selection clipboard -o'
alias vimcsed='nvim /home/omk/Storage/Insync/VIM/vim_cheatsheet.md'
alias vimcs='cd /home/omk/Storage/Insync/VIM/ && pandoc vim_cheatsheet.md -s -o vim_omk_cheatsheet.pdf && zathura vim_omk_cheatsheet.pdf & exit'
alias rdsep='cd /home/omk/MEGA/Documents\ M/Ruidos/Site\ Ruidos/ && nvim Ep00\ Template.html'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias docm='cd /home/omk/MEGA/Documents\ M/'
alias lnxmac='cd /home/omk/Storage/Insync/Linux/Linux/ && pandoc linux_on_mac.md -s -o linux_on_mac.pdf && zathura linux_on_mac.pdf & exit'
alias cdsite='cd /home/omk/MEGA/Documents\ M/WEBSITE/kavotaman.github.io/'
alias jekylls='bundle exec jekyll serve -l'
alias jekyllb='bundle exec jekyll build'
alias git-push='git add --all && git commit -m "hello" && git push'
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias post-tonal='cd /home/omk/Storage/Insync/DMA\ BGSU\ 2019-/2nd\ Year/S21\ Post-tonal\ Analysis'
alias disabilities='cd /home/omk/Storage/Insync/DMA\ BGSU\ 2019-/2nd\ Year/S21\ Music\ and\ Disabilities'
alias mega='cd /home/omk/MEGA'
alias dma='cd /home/omk/Storage/Insync/DMA\ BGSU\ 2019-'
alias wfon='nmcli radio wifi on'
alias wfoff='nmcli radio wifi off'
alias newsite='cd /home/omk/MEGA/Documents\ M/WEBSITE/TESTE/'
alias loja='cd /home/omk/MEGA/Documents\ M/WEBSITE/loja_ruidos/'

#set editor
export VISUAL=nvim;
export EDITOR=nvim;

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"
alias dotfiles2='/usr/bin/git --git-dir=/home/omk/.dotfiles2/ --work-tree=/home/omk'
