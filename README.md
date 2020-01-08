kctl: Kubernetes prompt for bash and zsh
============================================

A script that lets you add the current Kubernetes context and namespace
configured on `kubectl` to your Bash/Zsh prompt strings (i.e. the `$PS1`).

Inspired by several tools used to simplify usage of `kubectl`.

![prompt](img/prompt.png)

## Installing

### Antigen

```sh
antigen bundle ArnoBouts/kctl
```

### From Source

1. Clone this repository
2. Source the kctl.plugin.zsh in your `~/.zshrc` or your `~/.bashrc`

#### Zsh

Edit `.zshrc`
```sh
PROMPT='$(kctl)'$PROMPT
```

#### Bash

Edit `.bashrc`
```sh
PS1='[\u@\h \W $(kube_ps1)]\$ '
```

## Aliases

### Usefull commands

|Command           |Description                                                  |
|------------------|-------------------------------------------------------------|
|`ksetns namespace`|change current context namespace to `namespace`              |
|`kusectx context` |change current context to `context`                          |
|                  |                                                             |
|`kgpo`            |`kubectl get pod`                                            |
|`kglpo`           |`kubectl $last get pod` where $last is the last deployed pod |
|`klol`            |`kubectl logs -f $last` where $last is the last deployed pod |
|`kexl`            |`kubectl exec -it $last` where $last is the last deployed pod|


### Syntax explanation

`$last` refer to the last modified object

* **`k`**=`kubectl`
* commands:
  * **`g`**=`get`, **`gl`**=`get $last`
  * **`d`**=`describe`, **`dl`**=`describe $last`
  * **`rm`**=`delete`, **`rml`**=`delete $last`
  * **`a`**:`apply -f`
  * **`ak`**:`apply -k`
  * **`k`**:`kustomize`
  * **`ex`**: `exec -i -t`, **`exl`**: `exec -i -t $last`
  * **`lo`**: `logs -f`, **`lol`**=`logs -f $last`
* resources:
  * **`po`**=pod, **`dep`**=`deployment`, **`ing`**=`ingress`,
    **`svc`**=`service`, **`cm`**=`configmap`, **`sec`=`secret`**,
    **`ns`**=`namespace`, **`no`**=`node`
* flags:
  * **`all`**: `--all` or `--all-namespaces` depending on the command
  * **`w`**=`-w/--watch`

## Prompt Structure

The default prompt layout is:

```
(<symbol>|<context>:<namespace>)
```

If the current-context is not set, kctl will return the following:

```
(<symbol>|N/A:N/A)
```

## Enabling/Disabling

If you want to stop showing Kubernetes status on your prompt string temporarily
run `kctloff`. To disable the prompt for all shell sessions, run `kctloff -g`.
You can enable it again in the current shell by running `kctlon`, and globally
with `kctlon -g`.

```
kctlon     : turn on kctl status for this shell.  Takes precedence over
             global setting for current session
kctlon -g  : turn on kctl status globally
kctloff    : turn off kctl status for this shell. Takes precedence over
             global setting for current session
kctloff -g : turn off kctl status globally
```

## Customization

The default settings can be overridden in `~/.bashrc` or `~/.zshrc` by setting
the following environment variables:

| Variable | Default | Meaning |
| :------- | :-----: | ------- |
| `KCTL_BINARY` | `kubectl` | Default Kubernetes binary |
| `KCTL_NS_ENABLE` | `true` | Display the namespace. If set to `false`, this will also disable `KCTL_DIVIDER` |
| `KCTL_PREFIX` | `(` | Prompt opening character  |
| `KCTL_SYMBOL_ENABLE` | `true ` | Display the prompt Symbol. If set to `false`, this will also disable `KCTL_SEPARATOR` |
| `KCTL_SYMBOL_DEFAULT` | `⎈ ` | Default prompt symbol. Unicode `\u2388` |
| `KCTL_SYMBOL_USE_IMG` | `false` | ☸️  ,  Unicode `\u2638` as the prompt symbol |
| `KCTL_SEPARATOR` | &#124; | Separator between symbol and context name |
| `KCTL_DIVIDER` | `:` | Separator between context and namespace |
| `KCTL_SUFFIX` | `)` | Prompt closing character |
| `KCTL_CLUSTER_FUNCTION` | No default, must be user supplied | Function to customize how cluster is displayed |
| `KCTL_NAMESPACE_FUNCTION` | No default, must be user supplied | Function to customize how namespace is displayed |

For terminals that do not support UTF-8, the symbol will be replaced with the
string `k8s`.

To disable a feature, set it to an empty string:

```
KCTL_SEPARATOR=''
```

## Colors

The default colors are set with the following environment variables:

| Variable | Default | Meaning |
| :------- | :-----: | ------- |
| `KCTL_SYMBOL_COLOR` | `blue` | Set default color of the Kubernetes symbol |
| `KCTL_CTX_COLOR` | `red` | Set default color of the context |
| `KCTL_NS_COLOR` | `cyan` | Set default color of the namespace |
| `KCTL_BG_COLOR` | `null` | Set default color of the prompt background |

Blue was used for the default symbol to match the Kubernetes color as closely
as possible. Red was chosen as the context name to stand out, and cyan for the
namespace.

Set the variable to an empty string if you do not want color for each
prompt section:

```
KCTL_CTX_COLOR=''
```

Names are usable for the following colors:

```
black, red, green, yellow, blue, magenta, cyan
```

256 colors are available by specifying the numerical value as the variable
argument.

## Customize display of cluster name and namespace

You can change how the cluster name and namespace are displayed using the
`KCTL_CLUSTER_FUNCTION` and `KCTL_NAMESPACE_FUNCTION` variables
respectively.

For the following examples let's assume the following:

cluster name: `sandbox.k8s.example.com`
namespace: `alpha`

If you're using domain style cluster names, your prompt will get quite long
very quickly. Let's say you only want to display the first portion of the
cluster name (`sandbox`), you could do that by adding the following:

```sh
function get_cluster_short() {
  echo "$1" | cut -d . -f1
}

KCTL_CLUSTER_FUNCTION=get_cluster_short
```

The same pattern can be followed to customize the display of the namespace.
Let's say you would prefer the namespace to be displayed in all uppercase
(`ALPHA`), here's one way you could do that:

```sh
function get_namespace_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

export KCTL_NAMESPACE_FUNCTION=get_namespace_upper
```

In both cases, the variable is set to the name of the function, and you must have defined the function in your shell configuration before kube_ps1 is called. The function must accept a single parameter and echo out the final value.
