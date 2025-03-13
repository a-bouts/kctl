#!/bin/zsh
#
#
#

# Default values for the prompt
# Override these values in ~/.zshrc or ~/.bashrc
FLUX_ALIAS="${FLUX_BINARY:-flux}"
FLUX_BINARY=$(which ${FLUX_ALIAS})

if [ $? -ne 0 ]; then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `flux`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_flux" ]]; then
  typeset -g -A _comps
  autoload -Uz _flux
  _comps[flux]=_flux
fi

${FLUX_BINARY} completion zsh 2> /dev/null >| "$ZSH_CACHE_DIR/completions/_flux" &|

fx() {
  k_with_namespace "flux-system" k_with_context _kctl_trace ${FLUX_ALIAS} ${FLUX_BINARY} $@
}

_fx() {
  params=("${(@)words[2,$#words]}")
  words=("flux" "${$(_k_with_context)[@]}" "${$(_k_with_namespace "flux-system")[@]}" "${params[@]}")
  CURRENT=$#words
  _flux
}

compdef _fx fx

alias flux='fx'

# flux get
alias fxg='fx get'
alias fxgap='fxg alert-providers'
alias fxga='fxg alerts'
alias fxgall='fxg all'
alias fxghr='fxg helmreleases'
alias fxgim='fxg images'
alias fxgks='fxg kustomizations'
alias fxgr='fxg receivers'

alias fxgnok='fx get --status-selector ready=false'


alias fxgsrc='fxg sources all'
alias fxgchart='fxg sources chart'
alias fxggit='fxg sources git'
alias fxghrepo='fxg sources helm'
alias fxgoci='fxg sources oci'

# flux delete
alias fxrm='fx delete'
alias fxrmap='fxrm alert-provider'
alias fxrma='fxrm alert'
alias fxrmhr='fxrm helmrelease'
alias fxrmim='fxrm image'
alias fxrmks='fxrm kustomization'
alias fxrmr='fxrm receiver'

# flux events
alias fxe='fx events'

# flux logs
alias fxl='k_with_context _kctl_trace ${FLUX_ALIAS} ${FLUX_BINARY} logs'

# flux reconcile
alias fxrec='fx reconcile'
alias fxrechr='fxrec helmrelease'
alias fxrecim='fxrec image'
alias fxrecks='fxrec kustomization'
alias fxrecr='fxrec receiver'

alias fxrecsrc='fxrec source'
alias fxrecchart='fxrecsrc chart'
alias fxrecgit='fxrecsrc git'
alias fxrechrepo='fxrecsrc helm'
alias fxrecoci='fxrecsrc oci'

# flux resume
alias fxres='fx resume'
alias fxresap='fxres alert-provider'
alias fxresa='fxres alert'
alias fxreshr='fxres helmrelease'
alias fxresim='fxres image'
alias fxresks='fxres kustomization'
alias fxresr='fxres receiver'

alias fxressrc='fxres source'
alias fxreschart='fxres source chart'
alias fxresgit='fxres source git'
alias fxreshrepo='fxres source helm'
alias fxresoci='fxres source oci'

# flux suspend
alias fxsus='fx suspend'
alias fxsusap='fxsus alert-provider'
alias fxsusa='fxsus alert'
alias fxsushr='fxsus helmrelease'
alias fxsusim='fxsus image'
alias fxsusks='fxsus kustomization'
alias fxsusr='fxsus receiver'

alias fxsussrc='fxsus source'
alias fxsuschart='fxsus source chart'
alias fxsusgit='fxsus source git'
alias fxsushrepo='fxsus source helm'
alias fxsusoci='fxsus source oci'

# flux stats
alias fxst='fx stats'

# flux trace
alias fxtr='fx trace'

# flux tree
alias fxt='fx tree kustomization'


