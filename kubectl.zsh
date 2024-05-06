#!/bin/zsh
#
#
#

KCTL_BINARY="${KCTL_BINARY:-kubectl}"

if (( ! $+commands[${KCTL_BINARY}] )); then
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

k() {
  k_with_namespace $KCTL_NAMESPACE k_with_context _kctl_trace ${KCTL_BINARY} $@
}

_k() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "${params[@]}")
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
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "get" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _kgl kgl

# GET YAML
_kcy() {
  echo "\033[0;33m>\033[0m \033[1;30m${KCTL_BINARY} $@ | yh\033[0m">&2;
  command ${KCTL_BINARY} $@ | yh;
  echo "\033[0;33m<\033[0m \033[1;30m${KCTL_BINARY} $@ | yh\033[0m">&2;
}
function ky() {
  if ! _kctl_binary_check "yh"; then
    echo "You must install yh to enable yaml highlightening : https://github.com/andreazorzetto/yh" >&2
    k_with_namespace $KCTL_NAMESPACE k_with_context _kctl_trace ${KCTL_BINARY} get "$@" -o yaml
  else
    k_with_namespace $KCTL_NAMESPACE k_with_context _kcy get "$@" -o yaml
  fi
}
compdef _kgl ky

alias kypo='ky pod'
alias kysvc='ky service'
alias kydep='ky deployment'
alias kyrs='ky replicaset'
alias kyds='ky daemonset'
alias kyss='ky statefulset'
alias kying='ky ingress'
alias kycm='ky configmap'
alias kysec='ky secret'
alias kyns='ky namespace'
alias kyno='ky node'
alias kyr='ky role'
alias kyrb='ky rolebinding'
alias kycr='ky clusterrole'
alias kycrb='ky clusterrolebinding'
alias kypv='ky pv'
alias kypvc='ky pvc'
alias kyj='ky job'
alias kycj='ky cronjob'

function kylpo() {
  POD=$(kgpo $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kypo $POD $@
}

function kylrs() {
  RS=$(kgrs $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kyrs $RS $@
}

function kyl() {
  LAST=$(kg $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  ky $1 $LAST ${@:2}
}

_kyl() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "get" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _kyl kyl


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
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "describe" "${params[@]}")
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
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "delete" "${params[@]}")
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
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "edit" "${params[@]}")
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
    words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "get" "pod" "${params[@]}")
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
    words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "get" "service" "${params[@]}")
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
    words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "get" "deployment" "${params[@]}")
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
  _kctl_trace ${KCTL_BINARY} drain $1 --timeout=300s --ignore-daemonsets --force --delete-emptydir-data || _kctl_trace ${KCTL_BINARY} drain $1 --timeout=60s --disable-eviction --ignore-daemonsets --force --delete-emptydir-data
}

_kdrain() {
  params=("${(@)words[2,$#words]}")
  words=("kubectl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "drain" "${params[@]}")
  CURRENT=$#words
  _kubectl
}

compdef _kdrain kdrain


#
# Oh-My-Zsh Compatibility
#

# Apply a YML file
alias kaf='ka'

# Drop into an interactive terminal on a container
alias keti='kex'

# General aliases
alias kdel='krm'
alias kdelf='krm -f'

# Pod management.
alias kgp='kgpo'
alias kgpa='kgpo -A'
alias kgpw='kgpow'
alias kgpwide='kgpo -o wide'
alias kep='kepo'
alias kdp='kdpo'
alias kdelp='krmpo'
alias kgpall='kgpo -A -o wide'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgpo -l'

# get pod by namespace: kgpn kube-system"
alias kgpn='kgpo -n'

# Service management.
alias kgs='kgsvc'
alias kgsa='kgsvc --all-namespaces'
alias kgsw='kgsvc --watch'
alias kgswide='kgsvc -o wide'
alias kes='kesvc'
alias kds='kdsvc'
alias kdels='krmsvc'

# Ingress management
alias kgi='kging'
alias kgia='kging --all-namespaces'
alias kei='keing'
alias kdi='kding'
alias kdeli='krming'

# Namespace management
alias kdelns='krmns'
alias kcn='ksetns'

# ConfigMap management
alias kgcma='kgcm --all-namespaces'
alias kdelcm='krmcm'

# Secret management
alias kgseca='kgsec --all-namespaces'
alias kdelsec='krmsec'

# Deployment management.
alias kgd='kgdep'
alias kgda='kgdep --all-namespaces'
alias kgdw='kgdep --watch'
alias kgdwide='kgdep -o wide'
alias ked='kedep'
alias kdd='kddep'
alias kdeld='krmdep'
alias ksd='k scale deployment'
alias krsd='k rollout status deployment'

function kres(){
  k set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias krh='k rollout history'
alias kru='k rollout undo'

# Statefulset management.
alias kgssa='kgss --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kdelss='krmss'
alias ksss='k scale statefulset'
alias krsss='k rollout status statefulset'

# Tools for accessing all information
alias kga='k get all'
alias kgaa='k get all --all-namespaces'

# Logs
alias kl='klo'
alias kl1h='klo --since 1h'
alias kl1m='klo --since 1m'
alias kl1s='klo --since 1s'
alias klf='klo -f'
alias klf1h='klo --since 1h -f'
alias klf1m='klo --since 1m -f'
alias klf1s='klo --since 1s -f'

# File copy
alias kcp='k cp'

# Node Management
alias keno='k edit node'
alias kdelno='krmno'

# PVC management.
alias kgpvca='kgpvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kdelpvc='krmpvc'

# Service account management.
alias kdsa="k describe sa"
alias kdelsa="k delete sa"

# DaemonSet management.
alias kgdsa='kgds --all-namespaces'
alias kgdsw='kgds --watch'
alias kdelds='krmds'

# CronJob management.
alias kdelcj='krmcj'

# Job management.
alias kdelj='krmj'
