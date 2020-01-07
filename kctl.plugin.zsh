#
#
#
function kctl_prompt_info() {
    printf $NS
}

function ksetns() {
  export NS=$1
}

function kctlprint() {
  echo "+ kubectl $@">&2;
  command kubectl $@;
}

function kctl() {
  NAMESPACE_OVERRIDE=0
  for ARG in "$@"
  do
    if [[ $ARG == "-n" ]] || [[ $ARG == "--all-namespaces" ]]
    then
      NAMESPACE_OVERRIDE=1
    fi
  done
  if [ -z $NS ] || [[ $NAMESPACE_OVERRIDE == 1 ]]
  then
    kctlprint $@;
  else
    kctlprint -n $NS $@;
  fi
}

alias k='kctl'
alias kg='kctl get'
alias kgpo='kctl get pod'
alias kgsvc='kctl get service'
alias kgdep='kctl get deployment'
alias kgrs='kctl get replicaset'
alias kging='kctl get ingress'
alias kgcm='kctl get configmap'
alias kgsec='kctl get secret'
alias kgns='kctl get namespace'
alias kgno='kctl get node'
alias kgall='kctl get all'

function kglpo() {
  POD=$(kctl get pod $@ --sort-by={.metadata.creationTimestamp} -o=go-template --template='{{range .items}}{{(printf "%s\n" .metadata.name)}}{{end}}' 2>/dev/null | tail -1)
  kgpo $POD $@
}
