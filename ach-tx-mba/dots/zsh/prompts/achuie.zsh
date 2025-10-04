achuie='[%(!.%F{red}.%F{blue})%n@%m%f %1~${vcs_info_msg_0_}]%# '
achuievi='[%F{yellow}%n@%m%f %1~${vcs_info_msg_0_}]%# '

function set_prompt {
    case ${KEYMAP} in
        (vicmd) PS1=$achuievi ;;
        (main|viins) PS1=$achuie ;;
        (*) PS1=$achuie ;;
    esac

    if [[ -v VIRTUAL_ENV ]]; then
        PS1='%F{cyan}%B(venv)%b%f '$PS1
    fi

    RPS1='%F{red}%(?..(%?%))%f'
}

function prompt_achuie_precmd {
    vcs_info
    set_prompt
}

function zle-line-init zle-keymap-select {
    set_prompt
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

function prompt_achuie_setup {
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git

    zstyle ':vcs_info:*' check-for-staged-changes true
    zstyle ':vcs_info:*' stagedstr "+"
    zstyle ':vcs_info:*' patch-format "%c"
    zstyle ':vcs_info:*' nopatch-format "%c"
    zstyle ':vcs_info:*' actionformats " %F{green}(%b|%a)%c%m%f"
    zstyle ':vcs_info:*' formats " %F{green}(%b)%c%m%f"

    precmd_functions+=(prompt_achuie_precmd)
}

prompt_achuie_setup "$@"
