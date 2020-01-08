#!/bin/zsh
#
#
#
function ksetns() {
  kubectl config set-context --current --namespace=$1
}

kc() {
  echo "+ kubectl $@">&2;
  command kubectl $@;
}

alias k='kc'
# GET
alias kg='kc get'
alias kgpo='kc get pod'
alias kgpow='kc get pod -w'
alias kgsvc='kc get service'
alias kgdep='kc get deployment'
alias kgrs='kc get replicaset'
alias kging='kc get ingress'
alias kgcm='kc get configmap'
alias kgsec='kc get secret'
alias kgns='kc get namespace'
alias kgno='kc get node'
alias kgall='kc get all'

function kglpo() {
  POD=$(kc get pod $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kgpo $POD $@
}

function kglpow() {
  POD=$(kc get pod $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kgpow $POD $@
}

function kglrs() {
  RS=$(kc get reolicaset $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kgrs $RS $@
}

# DESCRIBE
alias kd='kc describe'
alias kdpo='kc describe pod'
alias kdpow='kc describe pod -w'
alias kdsvc='kc describe service'
alias kddep='kc describe deployment'
alias kdrs='kc describe replicaset'
alias kding='kc describe ingress'
alias kdcm='kc describe configmap'
alias kdsec='kc describe secret'
alias kdns='kc describe namespace'
alias kdno='kc describe node'

function kdlpo() {
  POD=$(kc get pod $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kdpo $POD $@
}

function kdlpow() {
  POD=$(kc get pod $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kdpow $POD $@
}

function kdlrs() {
  RS=$(kc get replicaset $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kdrs $RS $@
}

# DELETE
alias krm='kc delete'
alias krmf='kc deletei -f'
alias krmpo='kc delete pod'
alias krmsvc='kc delete service'
alias krmdep='kc delete deployment'
alias krmrs='kc delete replicaset'
alias krming='kc delete ingress'
alias krmcm='kc delete configmap'
alias krmsec='kc delete secret'
alias krmns='kc delete namespace'

function krmlpo() {
  POD=$(kc get pod $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  krmpo $POD $@
}

function krmlrs() {
  RS=$(kc get reolicaset $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  krmrs $RS $@
}

# APPLY
alias ka='kc apply -f'
alias kak='kc apply -k'

# LOG
alias klo='kc logs -f'

function klol() {
  POD=$(kc get pod $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  klo $POD $@
}

# EXEC
alias kex='kc exec -it'

function kexl() {
  POD=$(kc get pod $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kex $POD $@
}


# Debug
[[ -n $DEBUG ]] && set -x

setopt PROMPT_SUBST
autoload -U add-zsh-hook
add-zsh-hook precmd _kctl_update_cache
zmodload zsh/stat
zmodload zsh/datetime

# Default values for the prompt
# Override these values in ~/.zshrc
KCTL_BINARY="${KCTL_BINARY:-kubectl}"
KCTL_SYMBOL_ENABLE="${KCTL_SYMBOL_ENABLE:-true}"
KCTL_SYMBOL_DEFAULT="${KCTL_SYMBOL_DEFAULT:-\u2388 }"
KCTL_SYMBOL_USE_IMG="${KCTL_SYMBOL_USE_IMG:-false}"
KCTL_NS_ENABLE="${KCTL_NS_ENABLE:-true}"
KCTL_SEPARATOR="${KCTL_SEPARATOR-|}"
KCTL_DIVIDER="${KCTL_DIVIDER-:}"
KCTL_PREFIX="${KCTL_PREFIX-(}"
KCTL_SUFFIX="${KCTL_SUFFIX-)}"
KCTL_LAST_TIME=0
KCTL_ENABLED=true

KCTL_COLOR_SYMBOL="$fg[yellow]"
KCTL_COLOR_CONTEXT="$fg[red]"
KCTL_COLOR_NS="$fg[cyan]"

_kctl_binary_check() {
  command -v "$1" >/dev/null
}

_kctl_symbol() {
  [[ "${KCTL_SYMBOL_ENABLE}" == false ]] && return

  KCTL_SYMBOL="${KCTL_SYMBOL_DEFAULT}"
  KCTL_SYMBOL_IMG="\u2638 "

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

  zmodload -e "zsh/stat"
  if [[ "$?" -eq 0 ]]; then
    mtime=$(stat +mtime "${file}")
  elif stat -c "%s" /dev/null &> /dev/null; then
    # GNU stat
    mtime=$(stat -c %Y "${file}")
  else
    # BSD stat
    mtime=$(stat -f %m "$file")
  fi

  [[ "${mtime}" -gt "${check_time}" ]]
}

_kctl_update_cache() {
  KUBECONFIG="${KUBECONFIG:=$HOME/.kube/config}"
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
}

_kctl_get_context_ns() {

  # Set the command time
  KCTL_LAST_TIME=$EPOCHSECONDS

  KCTL_CONTEXT="$(${KCTL_BINARY} config current-context 2>/dev/null)"
  if [[ -z "${KCTL_CONTEXT}" ]]; then
    KCTL_CONTEXT="N/A"
    KCTL_NAMESPACE="N/A"
    return
  elif [[ "${KCTL_NS_ENABLE}" == true ]]; then
    KCTL_NAMESPACE="$(${KCTL_BINARY} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    # Set namespace to 'default' if it is not defined
    KCTL_NAMESPACE="${KCTL_NAMESPACE:-default}"
  fi
}

# function to disable the prompt on the current shell
kctlon(){
  KCTL_ENABLED=true
}

# function to disable the prompt on the current shell
kctloff(){
  KCTL_ENABLED=false
}

# Build our prompt
kctl() {
  local reset_color="$reset_color"
  [[ ${KCTL_ENABLED} != 'true' ]] && return

  KCTL="${reset_color}$KCTL_PREFIX"
  KCTL+="${KCTL_COLOR_SYMBOL}$(_kctl_symbol)"
  KCTL+="${reset_color}$KCTL_SEPERATOR"
  KCTL+="${KCTL_COLOR_CONTEXT}$KCTL_CONTEXT${reset_color}"
  KCTL+="$KCTL_DIVIDER"
  KCTL+="${KCTL_COLOR_NS}$KCTL_NAMESPACE${reset_color}"
  KCTL+="$KCTL_SUFFIX"

  echo "$KCTL"
}
