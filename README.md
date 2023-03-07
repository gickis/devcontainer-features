# Kubernetes cli tools

A Visual Studio code [dev container](https://containers.dev/) features.

Installs the following command line utilities:

* [kubeseal](https://github.com/bitnami-labs/sealed-secrets#readme)
* [kubeconform](https://github.com/yannh/kubeconform)
* [confd](https://github.com/abtreece/confd)
* [gomplate](https://github.com/hairyhenderson/gomplate)

Auto-detects latest version and installs needed dependencies.

## Usage

Latest version installed by default. You can pin a specific version or specify latest or none if you wish to have the latest version or skip the installation. Please see below for an example:

* kubeseal
```
"features": {
    "ghcr.io/gickis/devcontainer-features/kubeseal:1": {
        "version": "latest"
    }
}
```
* kubeconform
```
"features": {
    "ghcr.io/gickis/devcontainer-features/kubeconform:1": {
        "version": "latest"
    }
}
```
* confd
```
"features": {
    "ghcr.io/gickis/devcontainer-features/confd:1": {
        "version": "latest"
    }
}
```
* gomplate
```
"features": {
    "ghcr.io/gickis/devcontainer-features/gomplate:1": {
        "version": "latest"
    }
}
```