# PROMPT
autoload -Uz vcs_info
setopt prompt_subst

# Configure vcs_info for git
zstyle ':vcs_info:git:*' formats 'git:%F{blue}(%b) %f%F{yellow}%u%f%F{green}%c%f'
zstyle ':vcs_info:git:*' actionformats 'git:%F{blue}(%b|%a) %f%F{yellow}%u%f%F{green}%c%f'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '󱐌 ' # 󱐌 ●
zstyle ':vcs_info:*' stagedstr ' '  # ✚

# precmd(){
#     vcs_info
#     print ""
#     # print -P "%F{cyan}%~%f git:${vcs_info_msg_0_}"
# }
# PROMPT='%F{cyan}%~%f ${vcs_info_msg_0_}%(?.%F{cyan}%f.%F{red}%f) '

precmd(){
      vcs_info

      print ""

      local env_text=""
      if [[ -n ${VIRTUAL_ENV_PROMPT:-} ]]; then
          env_text=$VIRTUAL_ENV_PROMPT
      elif [[ -n ${CONDA_PROMPT_MODIFIER:-} ]]; then
          env_text=$CONDA_PROMPT_MODIFIER
      elif [[ -n ${VIRTUAL_ENV:-} ]]; then
          env_text="(${VIRTUAL_ENV:t})"
      fi

      local env_segment=""
      if [[ -n "$env_text" ]]; then
          env_segment="env:%F{magenta}${env_text//\%/%%}%f"
      fi

      # One with default path
      print -P "%F{cyan}%~%f ${env_segment}${vcs_info_msg_0_}"
  }

PROMPT="%(?.%F{cyan}󰘧%f.%F{red}󰘧%f) "
