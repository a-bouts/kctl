#!/bin/zsh
#
#
#

if (( ! $+commands[kubectl] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `kubectl`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_kubectl" ]]; then
  typeset -g -A _comps
  autoload -Uz _kubectl
  _comps[kubectl]=_kubectl
fi

kubectl completion zsh 2> /dev/null >| "$ZSH_CACHE_DIR/completions/_kubectl" &|

__kubectl_debug()
{
    local file="$BASH_COMP_DEBUG_FILE"
    if [[ -n ${file} ]]; then
        echo "$*" >> "${file}"
    fi
}

function ksetns() {
  ${KCTL_BINARY} config set-context --current --namespace=$1
  _kctl_get_ns
  _kctl_use_ns $1
}

function kns() {
  _kctl_use_ns $1
}

_kns() {
  __kubectl_debug "$(_k_with_context)"
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

kc() {
  echo "+ ${KCTL_BINARY} $@">&2;
  command ${KCTL_BINARY} $@;
}

k_with_namespace() {
  if [[ "$@" =~ "^(.* )?-n( .*)?$" || "$@" =~ "^(.* )?--namespace( .*)?$" || "$@" =~ "^(.* )?-A( .*)?$" || "$KCTL_USE_NAMESPACE" == "$KCTL_NAMESPACE" ]];
  then
    k_with_context $@;
  else
    k_with_context -n $KCTL_USE_NAMESPACE $@;
  fi
}

_k_with_namespace() {
  if [[ ${words[(ie)"-n"]} -lt ${#words} || ${words[(ie)"--namespace"]} -lt ${#words} || ${words[(ie)"-A"]} -lt ${#words} || "$KCTL_USE_NAMESPACE" == "$KCTL_NAMESPACE" ]];
  then
  else
    echo "--namespace" "$KCTL_USE_NAMESPACE"
  fi
}

k_with_context() {
  if [[ "$@" =~ "^(.* )?--context( .*)?$" || "$KCTL_USE_CONTEXT" == "$KCTL_CONTEXT" || -z "$KCTL_USE_CONTEXT" ]];
  then
    kc $@;
  else
    kc --context $KCTL_USE_CONTEXT $@;
  fi
}

_k_with_context() {
  if [[ ${words[(ie)"--context"]} -lt ${#words} || "$KCTL_USE_CONTEXT" == "$KCTL_CONTEXT" || -z "$KCTL_USE_CONTEXT" ]];
  then
  else
    echo "--context" "$KCTL_USE_CONTEXT"
  fi
}

k() {
  k_with_namespace $@
}

_k() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _k k

# GET
alias kg='k get'
alias kgpo='kg pod'
alias kgpow='kg pod -w'
alias kgsvc='kg service'
alias kgdep='kg deployment'
alias kgrs='kg replicaset'
alias kgds='kg daemonset'
alias kgss='kg statefulset'
alias kging='kg ingress'
alias kgcm='kg configmap'
alias kgsec='kg secret'
alias kgns='kg namespace'
alias kgno='kg node -o wide'
alias kgr='kg role'
alias kgrb='kg rolebinding'
alias kgcr='kg clusterrole'
alias kgcrb='kg clusterrolebinding'
alias kgpv='kg pv'
alias kgpvc='kg pvc'
alias kgall='kg all'
alias kgj='kg job'
alias kgcj='kg cronjob'

function kglpo() {
  POD=$(kgpo $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kgpo $POD $@
}

function kglpow() {
  POD=$(kgpo $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kgpow $POD $@
}

function kglrs() {
  RS=$(kgrs $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kgrs $RS $@
}

function kgl() {
  LAST=$(kg $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kg $1 $LAST ${@:2}
}

_kgl() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "get" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _kgl kgl

# DESCRIBE
alias kd='k describe'
alias kdpo='kd pod'
alias kdsvc='kd service'
alias kddep='kd deployment'
alias kdrs='kd replicaset'
alias kdds='kd daemonset'
alias kdss='kd statefulset'
alias kding='kd ingress'
alias kdcm='kd configmap'
alias kdsec='kd secret'
alias kdns='kd namespace'
alias kdno='kd node'
alias kdr='kd role'
alias kdrb='kd rolebinding'
alias kdcr='kd clusterrole'
alias kdcrb='kd clusterrolebinding'
alias kdpvc='kd pvc'
alias kdpv='kd pv'
alias kdj='kd job'
alias kdcj='kd cronjob'

function kdlpo() {
  POD=$(kgpo $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kdpo $POD $@
}

function kdlrs() {
  RS=$(kgrs $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kdrs $RS $@
}

function kdl() {
  LAST=$(kg $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kd $1 $LAST ${@:2}
}

_kdl() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "describe" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _kdl kdl

# DELETE
alias krm='k delete'
alias krmf='krm -f'
alias krmk='krm -k'
alias krmpo='krm pod'
alias krmsvc='krm service'
alias krmdep='krm deployment'
alias krmrs='krm replicaset'
alias krmds='krm daemonset'
alias krmss='krm statefulset'
alias krming='krm ingress'
alias krmcm='krm configmap'
alias krmsec='krm secret'
alias krmns='krm namespace'
alias krmno='krm node'
alias krmr='krm role'
alias krmrb='krm rolebinding'
alias krmcr='krm clusterrole'
alias krmcrb='krm clusterrolebinding'
alias krmpvc='krm pvc'
alias krmpv='krm pv'
alias krmj='krm job'
alias krmcj='krm cronjob'

function krmlpo() {
  POD=$(kgpo $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  krmpo $POD $@
}

function krmlrs() {
  RS=$(kgrs $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  krmrs $RS $@
}

function krml() {
  LAST=$(kg $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  krm $1 $LAST ${@:2}
}

_krml() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "delete" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _krml krml

# EDIT
alias ke='k edit'
alias kepo='ke pod'
alias kesvc='ke service'
alias kedep='ke deployment'
alias kers='ke replicaset'
alias kess='ke statefulset'
alias keds='ke daemonset'
alias keing='ke ingress'
alias kecm='ke configmap'
alias kesec='ke secret'
alias kens='ke namespace'
alias ker='ke role'
alias kerb='ke rolebinding'
alias kecr='ke clusterrole'
alias kecrb='ke clusterrolebinding'
alias kepvc='ke pvc'
alias kepv='ke pv'
alias kej='ke job'
alias kecj='ke cronjob'

function kelpo() {
  POD=$(kgpo $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kepo $POD $@
}

function kelrs() {
  RS=$(kgrs $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kers $RS $@
}

function kel() {
  LAST=$(kg $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  ke $1 $LAST ${@:2}
}

_kel() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "edit" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _kel kel

# APPLY
alias ka='k apply -f'
alias kk='k apply -k'

# LOG
alias klo='k logs -f'

function klol() {
  POD=$(kgpo $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  klo $POD $@
}

# EXEC
alias kex='k exec -it'

function kexl() {

  NMSPC=$KCTL_USE_NAMESPACE
  if [[ "$@" =~ "(^| )-n .*" ]];
  then
    NMSPC=`grep -o -e '-n [^ ]*[ $]' <<< $@ | cut -d" " -f2`
  elif [[ "$@" =~ "(^| )--namespace .*" ]];
  then
    NMSPC=`grep -o -e '--namespace [^ ]*[ $]' <<< $@ | cut -d" " -f2`
  fi

  POD=$(kgpo -n $NMSPC --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kex $POD $@
}


# PORT FORWARD
alias kpf='k port-forward'

function kpfpo() {
  kpf pod/$@
}

_kpfpo() {
  if [[ $#words -lt 3 ]]
  then
    params=("${(@)words[2,$#words]}")
    words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "get" "pod" "${params[@]}")
    CURRENT=$#words
    _kubectl
  fi
}

compdef _kpfpo kpfpo

function kpfsvc() {
  kpf service/$@
}

_kpfsvc() {
  if [[ $#words -lt 3 ]]
  then
    params=("${(@)words[2,$#words]}")
    words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "get" "service" "${params[@]}")
    CURRENT=$#words
    _kubectl
  fi
}

compdef _kpfsvc kpfsvc

function kpfdep() {
  kpf deployment/$@
}

_kpfdep() {
  if [[ $#words -lt 3 ]]
  then
    params=("${(@)words[2,$#words]}")
    words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "get" "deployment" "${params[@]}")
    CURRENT=$#words
    _kubectl
  fi
}

compdef _kpfdep kpfdep

function kpflpo() {

  NMSPC=$KCTL_USE_NAMESPACE
  if [[ "$@" =~ "(^| )-n .*" ]];
  then
    NMSPC=`grep -o -e '-n [^ ]*[ $]' <<< $@ | cut -d" " -f2`
  elif [[ "$@" =~ "(^| )--namespace .*" ]];
  then
    NMSPC=`grep -o -e '--namespace [^ ]*[ $]' <<< $@ | cut -d" " -f2`
  fi

  POD=$(kgpo -n $NMSPC --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kpfpo $POD $@
}


# DRAIN
function kdrain() {
  kc drain $1 --timeout=300s --ignore-daemonsets --force --delete-emptydir-data || kc drain $1 --timeout=60s --disable-eviction --ignore-daemonsets --force --delete-emptydir-data
}

_kdrain() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace)[@]}" "drain" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _kdrain kdrain


# Debug
[[ -n $DEBUG ]] && set -x

# Default values for the prompt
# Override these values in ~/.zshrc or ~/.bashrc
KCTL_BINARY="${KCTL_BINARY:-kubectl}"
KCTL_SYMBOL_ENABLE="${KCTL_SYMBOL_ENABLE:-true}"
KCTL_SYMBOL_DEFAULT=${KCTL_SYMBOL_DEFAULT:-$'\u2388 '}
KCTL_SYMBOL_USE_IMG="${KCTL_SYMBOL_USE_IMG:-false}"
KCTL_NS_ENABLE="${KCTL_NS_ENABLE:-true}"
KCTL_CONTEXT_ENABLE="${KCTL_CONTEXT_ENABLE:-true}"
KCTL_PREFIX="${KCTL_PREFIX-(}"
KCTL_SEPARATOR="${KCTL_SEPARATOR-}"
KCTL_DIVIDER="${KCTL_DIVIDER-:}"
KCTL_SUFFIX="${KCTL_SUFFIX-) }"
KCTL_SYMBOL_COLOR="${KCTL_SYMBOL_COLOR-12}"
KCTL_CTX_COLOR="${KCTL_CTX_COLOR-red}"
KCTL_NS_COLOR="${KCTL_NS_COLOR-cyan}"
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
  _kctl_use_context "${KCTL_CONTEXT}"
  _kctl_use_ns "${KCTL_NAMESPACE}"
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
    kubectl version --context "$1" 1>/dev/null
    if [ $? -eq 0 ]
    then
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
    KCTL_NAMESPACE="$(k_with_context config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
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
    _kubeon_usage
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
    _kubeoff_usage
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

  # Background Color
  [[ -n "${KCTL_BG_COLOR}" ]] && KCTL+="$(_kctl_color_bg ${KCTL_BG_COLOR})"

  # Prefix
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

  # Suffix
  [[ -n "${KCTL_SUFFIX}" ]] && KCTL+="${KCTL_SUFFIX}"

  # Close Background color if defined
  [[ -n "${KCTL_BG_COLOR}" ]] && KCTL+="${_KCTL_OPEN_ESC}${_KCTL_DEFAULT_BG}${_KCTL_CLOSE_ESC}"

  echo "${KCTL}"
}
