#!/bin/zsh
#
#
#

KCTL_ALIAS="${KCTL_BINARY:-kubectl}"
KCTL_BINARY=$(which ${KCTL_ALIAS})

if [ $? -ne 0 ]; then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `kubectl`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_kubectl" ]]; then
  typeset -g -A _comps
  autoload -Uz _kubectl
  _comps[kubectl]=_kubectl
fi

${KCTL_BINARY} completion zsh 2> /dev/null >| "$ZSH_CACHE_DIR/completions/_kubectl" &|

function ksetns() {
  ${KCTL_BINARY} config set-context ${KCTL_USE_CONTEXT} --namespace=$1
  _kctl_get_ns
  _kctl_use_ns $1
}

function kns() {
  _kctl_use_ns $1
}

_kns() {
  words=("kubectl" "${$(_k_with_context)[@]}" "get" "namespace" "${(@)words[2,$#words]}")
  CURRENT=$#words
  _kubectl
}

compdef _kns kns
compdef _kns ksetns

function ksetctx() {
  ${KCTL_BINARY} config use-context $1
  if [ $? -eq 0 ]
  then
    _kctl_use_context $1
  fi
}

function kctx() {
  _kctl_use_context $1
}

_kctx() {
  words=("kubectl" "config" "use-context" "${(@)words[2,$#words]}")
  CURRENT=$#words
  _kubectl
}

compdef _kctx kctx
compdef _kctx ksetctx

_kctl_trace() {
  alias=$1
  command=$2
  attrs=${@:3}

  echo "\033[0;33m>\033[0m \033[1;30m$alias $attrs\033[0m">&2
  command ${@:2}
  result=$?
  echo "\033[0;33m<\033[0m \033[1;30m$alias $attrs\033[0m">&2
  return result
}

k_with_namespace() {
  DEFAULT_NAMESPACE=$1
  if [[ "${@:6}" =~ "^(.* )?-n( .*)?$" || "${@:6}" =~ "^(.* )?--namespace( .*)?$" || "${@:6}" =~ "^(.* )?-A( .*)?$" || "$KCTL_USE_NAMESPACE" == "$DEFAULT_NAMESPACE" ]];
  then
    $2 $3 $4 $5 ${@:6};
  else
    $2 $3 $4 $5 -n $KCTL_USE_NAMESPACE ${@:6};
  fi
  KCTL_STATE=$?
  return $KCTL_STATE
}

_k_with_namespace() {
  DEFAULT_NAMESPACE=$1
  if [[ ${words[(ie)"-n"]} -lt ${#words} || ${words[(ie)"--namespace"]} -lt ${#words} || ${words[(ie)"-A"]} -lt ${#words} || "$KCTL_USE_NAMESPACE" == "$DEFAULT_NAMESPACE" ]];
  then
  else
    echo "--namespace" "$KCTL_USE_NAMESPACE"
  fi
}

k_with_context() {
  if [[ "${@:4}" =~ "^(.* )?--context( .*)?$" || "${@:4}" =~ "^(.* )?(set|use)-context( .*)?$" || "$KCTL_USE_CONTEXT" == "$KCTL_CONTEXT" || -z "$KCTL_USE_CONTEXT" ]];
  then
    $1 $2 $3 ${@:4};
  else
    $1 $2 $3 --context $KCTL_USE_CONTEXT ${@:4};
  fi
}

_k_with_context() {
  if [[ ${words[(ie)"--context"]} -lt ${#words} || ${words[(ie)"(set|use)-context"]} -lt ${#words} || "$KCTL_USE_CONTEXT" == "$KCTL_CONTEXT" || -z "$KCTL_USE_CONTEXT" ]];
  then
  else
    echo "--context" "$KCTL_USE_CONTEXT"
  fi
}


# Debug
[[ -n $DEBUG ]] && set -x

# Default values for the prompt
# Override these values in ~/.zshrc or ~/.bashrc
KCTL_SYMBOL_ENABLE="${KCTL_SYMBOL_ENABLE:-true}"
KCTL_SYMBOL_DEFAULT=${KCTL_SYMBOL_DEFAULT:-$'\u2388 '}
KCTL_SYMBOL_USE_IMG="${KCTL_SYMBOL_USE_IMG:-false}"
KCTL_NS_ENABLE="${KCTL_NS_ENABLE:-true}"
KCTL_CONTEXT_ENABLE="${KCTL_CONTEXT_ENABLE:-true}"
KCTL_PREFIX="${KCTL_PREFIX-[}"
KCTL_SEPARATOR="${KCTL_SEPARATOR-}"
KCTL_DIVIDER="${KCTL_DIVIDER-:}"
KCTL_SUFFIX="${KCTL_SUFFIX-] }"
KCTL_PREFIX_COLOR="${KCTL_PREFIX_COLOR-12}"
KCTL_SYMBOL_COLOR="${KCTL_SYMBOL_COLOR-12}"
KCTL_CTX_COLOR="${KCTL_CTX_COLOR-69}"
KCTL_NS_COLOR="${KCTL_NS_COLOR-12}"
KCTL_SUFFIX_COLOR="${KCTL_SUFFIX_COLOR-12}"
KCTL_TIP_COLOR="${KCTL_TIP_COLOR-yellow}"
KCTL_BG_COLOR="${KCTL_BG_COLOR}"
KCTL_KUBECONFIG_CACHE="${KUBECONFIG}"
KCTL_DISABLE_PATH="${HOME}/.kube/kctl/disabled"
KCTL_LAST_TIME=0
KCTL_CLUSTER_FUNCTION="${KCTL_CLUSTER_FUNCTION}"
KCTL_NAMESPACE_FUNCTION="${KCTL_NAMESPACE_FUNCTION}"

# Determine our shell
if [ "${ZSH_VERSION-}" ]; then
  KCTL_SHELL="zsh"
elif [ "${BASH_VERSION-}" ]; then
  KCTL_SHELL="bash"
fi

_kctl_init() {
  [[ -f "${KCTL_DISABLE_PATH}" ]] && KCTL_ENABLED=off

  case "${KCTL_SHELL}" in
    "zsh")
      _KCTL_OPEN_ESC="%{"
      _KCTL_CLOSE_ESC="%}"
      _KCTL_DEFAULT_BG="%k"
      _KCTL_DEFAULT_FG="%f"
      setopt PROMPT_SUBST
      autoload -U add-zsh-hook
      #add-zsh-hook precmd _kctl_update_cache
      add-zsh-hook preexec _kctl_update_cache
      zmodload -F zsh/stat b:zstat
      zmodload zsh/datetime
      ;;
    "bash")
      _KCTL_OPEN_ESC=$'\001'
      _KCTL_CLOSE_ESC=$'\002'
      _KCTL_DEFAULT_BG=$'\033[49m'
      _KCTL_DEFAULT_FG=$'\033[39m'
      [[ $PROMPT_COMMAND =~ _kctl_update_cache ]] || PROMPT_COMMAND="_kctl_update_cache;${PROMPT_COMMAND:-:}"
      ;;
  esac
  _kctl_update_cache
  _kctl_use_context ${KCTL_USE_CONTEXT:-"${KCTL_CONTEXT}"}
  _kctl_use_ns ${KCTL_USE_NAMESPACE:-"${KCTL_NAMESPACE}"}
}

_kctl_color_fg() {
  local KCTL_FG_CODE
  case "${1}" in
    black) KCTL_FG_CODE=0;;
    red) KCTL_FG_CODE=1;;
    green) KCTL_FG_CODE=2;;
    yellow) KCTL_FG_CODE=3;;
    blue) KCTL_FG_CODE=4;;
    magenta) KCTL_FG_CODE=5;;
    cyan) KCTL_FG_CODE=6;;
    white) KCTL_FG_CODE=7;;
    # 256
    [0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-6]) KCTL_FG_CODE="${1}";;
    *) KCTL_FG_CODE=default
  esac

  if [[ "${KCTL_FG_CODE}" == "default" ]]; then
    KCTL_FG_CODE="${_KCTL_DEFAULT_FG}"
    return
  elif [[ "${KCTL_SHELL}" == "zsh" ]]; then
    KCTL_FG_CODE="%F{$KCTL_FG_CODE}"
  elif [[ "${KCTL_SHELL}" == "bash" ]]; then
    if tput setaf 1 &> /dev/null; then
      KCTL_FG_CODE="$(tput setaf ${KCTL_FG_CODE})"
    elif [[ $KCTL_FG_CODE -ge 0 ]] && [[ $KCTL_FG_CODE -le 256 ]]; then
      KCTL_FG_CODE="\033[38;5;${KCTL_FG_CODE}m"
    else
      KCTL_FG_CODE="${_KCTL_DEFAULT_FG}"
    fi
  fi
  echo ${_KCTL_OPEN_ESC}${KCTL_FG_CODE}${_KCTL_CLOSE_ESC}
}

_kctl_color_bg() {
  local KCTL_BG_CODE
  case "${1}" in
    black) KCTL_BG_CODE=0;;
    red) KCTL_BG_CODE=1;;
    green) KCTL_BG_CODE=2;;
    yellow) KCTL_BG_CODE=3;;
    blue) KCTL_BG_CODE=4;;
    magenta) KCTL_BG_CODE=5;;
    cyan) KCTL_BG_CODE=6;;
    white) KCTL_BG_CODE=7;;
    # 256
    [0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-6]) KCTL_BG_CODE="${1}";;
    *) KCTL_BG_CODE=$'\033[0m';;
  esac

  if [[ "${KCTL_BG_CODE}" == "default" ]]; then
    KCTL_FG_CODE="${_KCTL_DEFAULT_BG}"
    return
  elif [[ "${KCTL_SHELL}" == "zsh" ]]; then
    KCTL_BG_CODE="%K{$KCTL_BG_CODE}"
  elif [[ "${KCTL_SHELL}" == "bash" ]]; then
    if tput setaf 1 &> /dev/null; then
      KCTL_BG_CODE="$(tput setab ${KCTL_BG_CODE})"
    elif [[ $KCTL_BG_CODE -ge 0 ]] && [[ $KCTL_BG_CODE -le 256 ]]; then
      KCTL_BG_CODE="\033[48;5;${KCTL_BG_CODE}m"
    else
      KCTL_BG_CODE="${DEFAULT_BG}"
    fi
  fi
  echo ${OPEN_ESC}${KCTL_BG_CODE}${CLOSE_ESC}
}

_kctl_binary_check() {
  command -v $1 >/dev/null
}

_kctl_symbol() {
  [[ "${KCTL_SYMBOL_ENABLE}" == false ]] && return

  case "${KCTL_SHELL}" in
    bash)
      if ((BASH_VERSINFO[0] >= 4)) && [[ $'\u2388 ' != "\\u2388 " ]]; then
        KCTL_SYMBOL="${KCTL_SYMBOL_DEFAULT}"
        # KCTL_SYMBOL=$'\u2388 '
        KCTL_SYMBOL_IMG=$'\u2638 '
      else
        KCTL_SYMBOL=$'\xE2\x8E\x88 '
        KCTL_SYMBOL_IMG=$'\xE2\x98\xB8 '
      fi
      ;;
    zsh)
      KCTL_SYMBOL="${KCTL_SYMBOL_DEFAULT}"
      KCTL_SYMBOL_IMG="\u2638 ";;
    *)
      KCTL_SYMBOL="k8s"
  esac

  if [[ "${KCTL_SYMBOL_USE_IMG}" == true ]]; then
    KCTL_SYMBOL="${KCTL_SYMBOL_IMG}"
  fi

  echo "${KCTL_SYMBOL}"
}

_kctl_split() {
  type setopt >/dev/null 2>&1 && setopt SH_WORD_SPLIT
  local IFS=$1
  echo $2
}

_kctl_file_newer_than() {
  local mtime
  local file=$1
  local check_time=$2

  if [[ "${KCTL_SHELL}" == "zsh" ]]; then
    mtime=$(zstat -L +mtime "${file}")
  elif stat -c "%s" /dev/null &> /dev/null; then
    # GNU stat
    mtime=$(stat -L -c %Y "${file}")
  else
    # BSD stat
    mtime=$(stat -L -f %m "$file")
  fi

  [[ "${mtime}" -gt "${check_time}" ]]
}

_kctl_update_cache() {
  local return_code=$?

  [[ "${KCTL_ENABLED}" == "off" ]] && return $return_code

  if ! _kctl_binary_check "${KCTL_BINARY}"; then
    # No ability to fetch context/namespace; display N/A.
    KCTL_CONTEXT="BINARY-N/A"
    KCTL_NAMESPACE="N/A"
    return
  fi

  if [[ "${KUBECONFIG}" != "${KCTL_KUBECONFIG_CACHE}" ]]; then
    # User changed KUBECONFIG; unconditionally refetch.
    KCTL_KUBECONFIG_CACHE=${KUBECONFIG}
    _kctl_get_context_ns
    return
  fi

  # kubectl will read the environment variable $KUBECONFIG
  # otherwise set it to ~/.kube/config
  local conf
  for conf in $(_kctl_split : "${KUBECONFIG:-${HOME}/.kube/config}"); do
    [[ -r "${conf}" ]] || continue
    if _kctl_file_newer_than "${conf}" "${KCTL_LAST_TIME}"; then
      _kctl_get_context_ns
      return
    fi
  done

  return $return_code
}

_kctl_get_context() {
  if [[ "${KCTL_CONTEXT_ENABLE}" == true ]]; then
    KCTL_CONTEXT="$(${KCTL_BINARY} config current-context 2>/dev/null)"
    # Set namespace to 'N/A' if it is not defined
    KCTL_CONTEXT="${KCTL_CONTEXT:-N/A}"
  fi
}

_kctl_use_context() {
  if [[ "${KCTL_CONTEXT_ENABLE}" == true ]]
  then
    ${KCTL_BINARY} config get-contexts "$1" 1>/dev/null
    if [ $? -eq 0 ]
    then
      ${KCTL_BINARY} version --context "$1" 1>/dev/null
      KCTL_STATE=$?

      KCTL_USE_CONTEXT="$1"
      if [[ ! -z "${KCTL_CLUSTER_FUNCTION}" ]]; then
        $KCTL_CLUSTER_FUNCTION $KCTL_USE_CONTEXT
      fi
      # Reload namespace from context
      _kctl_get_ns
      # Use this namespace
      _kctl_use_ns "$KCTL_NAMESPACE"
    fi
  fi
}

_kctl_get_ns() {
  if [[ "${KCTL_NS_ENABLE}" == true ]]; then
    KCTL_NAMESPACE="$(k_with_context _kctl_trace ${KCTL_ALIAS} ${KCTL_BINARY} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    # Set namespace to 'default' if it is not defined
    KCTL_NAMESPACE="${KCTL_NAMESPACE:-default}"
  fi
}

_kctl_use_ns() {
  if [[ "${KCTL_NS_ENABLE}" == true ]]
  then
    KCTL_USE_NAMESPACE="$1"
    if [[ ! -z "${KCTL_NAMESPACE_FUNCTION}" ]]; then
        $KCTL_NAMESPACE_FUNCTION $KCTL_USE_NAMESPACE
    fi
  fi
}

_kctl_get_context_ns() {
  # Set the command time
  if [[ "${KCTL_SHELL}" == "bash" ]]; then
    if ((BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 2)); then
      KCTL_LAST_TIME=$(printf '%(%s)T')
    else
      KCTL_LAST_TIME=$(date +%s)
    fi
  elif [[ "${KCTL_SHELL}" == "zsh" ]]; then
    KCTL_LAST_TIME=$EPOCHSECONDS
  fi

  _kctl_get_context
  _kctl_get_ns
}

# Set kctl shell defaults
_kctl_init

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

source "${0:A:h}/flux.zsh"
source "${0:A:h}/kubectl.zsh"
source "${0:A:h}/sylvactl.zsh"

_kctlon_usage() {
  cat <<"EOF"
Toggle kctl prompt on
Usage: kctlon [-g | --global] [-h | --help]
With no arguments, turn off kctl status for this shell instance (default).
  -g --global  turn on kctl status globally
  -h --help    print this message
EOF
}

_kctloff_usage() {
  cat <<"EOF"
Toggle kctl prompt off
Usage: kubeoff [-g | --global] [-h | --help]
With no arguments, turn off kctl status for this shell instance (default).
  -g --global turn off kctl status globally
  -h --help   print this message
EOF
}

kctlon() {
  if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
    _kctlon_usage
  elif [[ "${1}" == '-g' || "${1}" == '--global' ]]; then
    rm -f -- "${KCTL_DISABLE_PATH}"
  elif [[ "$#" -ne 0 ]]; then
    echo -e "error: unrecognized flag ${1}\\n"
    _kctlon_usage
    return
  fi

  KCTL_ENABLED=on
}

kctloff() {
  if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
    _kctloff_usage
  elif [[ "${1}" == '-g' || "${1}" == '--global' ]]; then
    mkdir -p -- "$(dirname "${KCTL_DISABLE_PATH}")"
    touch -- "${KCTL_DISABLE_PATH}"
  elif [[ $# -ne 0 ]]; then
    echo "error: unrecognized flag ${1}" >&2
    _kctloff_usage
    return
  fi

  KCTL_ENABLED=off
}

# Build our prompt
kctl() {
  [[ "${KCTL_ENABLED}" == "off" ]] && return
  [[ -z "${KCTL_USE_CONTEXT}" ]] && [[ "${KCTL_CONTEXT_ENABLE}" == true ]] && return

  local KCTL
  local KCTL_RESET_COLOR="${_KCTL_OPEN_ESC}${_KCTL_DEFAULT_FG}${_KCTL_CLOSE_ESC}"

  local CTX=$(echo ${KCTL_USE_CONTEXT} | sed 's/[^a-zA-Z0-9]/_/g')
  local CTX_BG_COLOR=$(eval 'echo $'"KCTL_${CTX}_BG_COLOR")
  local KCTL_BG_COLOR=${CTX_BG_COLOR:-$KCTL_BG_COLOR}

  local CTX_PREFIX_COLOR=$(eval 'echo $'"KCTL_${CTX}_PREFIX_COLOR")
  local KCTL_PREFIX_COLOR=${CTX_PREFIX_COLOR:-$KCTL_PREFIX_COLOR}

  local CTX_SYMBOL_COLOR=$(eval 'echo $'"KCTL_${CTX}_SYMBOL_COLOR")
  local KCTL_SYMBOL_COLOR=${CTX_SYMBOL_COLOR:-$KCTL_SYMBOL_COLOR}

  local CTX_CTX_COLOR=$(eval 'echo $'"KCTL_${CTX}_CTX_COLOR")
  local KCTL_CTX_COLOR=${CTX_CTX_COLOR:-$KCTL_CTX_COLOR}

  local CTX_NS_COLOR=$(eval 'echo $'"KCTL_${CTX}_NS_COLOR")
  local KCTL_NS_COLOR=${CTX_NS_COLOR:-$KCTL_NS_COLOR}

  local CTX_SUFFIX_COLOR=$(eval 'echo $'"KCTL_${CTX}_SUFFIX_COLOR")
  local KCTL_SUFFIX_COLOR=${CTX_SUFFIX_COLOR:-$KCTL_SUFFIX_COLOR}

  # Background Color
  [[ -n "${KCTL_BG_COLOR}" ]] && KCTL+="$(_kctl_color_bg ${KCTL_BG_COLOR})"

  # Prefix
  [[ -n "${KCTL_PREFIX_COLOR}" ]] && KCTL+="$(_kctl_color_fg ${KCTL_PREFIX_COLOR})"
  [[ -n "${KCTL_PREFIX}" ]] && KCTL+="${KCTL_PREFIX}"

  # Symbol
  KCTL+="$(_kctl_color_fg $KCTL_SYMBOL_COLOR)$(_kctl_symbol)${KCTL_RESET_COLOR}"

  if [[ -n "${KCTL_SEPARATOR}" ]] && [[ "${KCTL_SYMBOL_ENABLE}" == true ]]; then
    KCTL+="${KCTL_SEPARATOR}"
  fi

  # Context
  if [[ "${KCTL_CONTEXT_ENABLE}" == true ]]; then
    KCTL+="$(_kctl_color_fg $KCTL_CTX_COLOR)${KCTL_USE_CONTEXT}${KCTL_RESET_COLOR}"
  fi

  # Namespace
  if [[ "${KCTL_NS_ENABLE}" == true ]]; then
    if [[ -n "${KCTL_DIVIDER}" ]] && [[ "${KCTL_CONTEXT_ENABLE}" == true ]]; then
      KCTL+="${KCTL_DIVIDER}"
    fi
    KCTL+="$(_kctl_color_fg ${KCTL_NS_COLOR})${KCTL_USE_NAMESPACE}${KCTL_RESET_COLOR}"
  fi

  # State
  [[ "${KCTL_STATE}" == "0" ]] || KCTL+=" %{$fg[yellow]%}%1{✗%}"

  # Suffix
  [[ -n "${KCTL_SUFFIX_COLOR}" ]] && KCTL+="$(_kctl_color_fg ${KCTL_SUFFIX_COLOR})"
  [[ -n "${KCTL_SUFFIX}" ]] && KCTL+="${KCTL_SUFFIX}${KCTL_RESET_COLOR}"

  # Close Background color if defined
  [[ -n "${KCTL_BG_COLOR}" ]] && KCTL+="${_KCTL_OPEN_ESC}${_KCTL_DEFAULT_BG}${_KCTL_CLOSE_ESC}"

  echo "${KCTL}"
}
