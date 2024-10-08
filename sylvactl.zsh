#!/bin/zsh
#
#
#

# Default values for the prompt
# Override these values in ~/.zshrc or ~/.bashrc
SYLVA_ALIAS="${SYLVA_BINARY:-sylvactl}"
SYLVA_BINARY=$(which ${SYLVA_ALIAS})

if [ $? -ne 0 ]; then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `flux`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_sylvactl" ]]; then
  typeset -g -A _comps
  autoload -Uz _sylvactl
  _comps[sylvactl]=_sylvactl
fi

${SYLVA_BINARY} completion zsh 2> /dev/null >| "$ZSH_CACHE_DIR/completions/_sylvactl" &|

sy() {
  k_with_namespace k_with_context _kctl_trace ${SYLVA_ALIAS} ${SYLVA_BINARY} $@
}

_sy() {
  params=("${(@)words[2,$#words]}")
  words=("sylvactl" "${$(_k_with_context)[@]}" "${$(_k_with_namespace $KCTL_NAMESPACE)[@]}" "${params[@]}")
  CURRENT=$#words
  _sylvactl
}

compdef _sy sy

alias sylvactl='sy'
