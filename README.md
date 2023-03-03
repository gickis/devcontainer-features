# Kubernetes cli tools

A Visual Studio code [dev container](https://containers.dev/) features.

Installs the following command line utilities:

* [kubeseal](https://github.com/bitnami-labs/sealed-secrets#readme)
* [kubeconform](https://github.com/yannh/kubeconform)

Auto-detects latest version and installs needed dependencies.

## Usage

Latest version installed by default. You can pin a specific version or specify latest or none if you wish to have the latest version or skip the installation. Please see below for an example:

* kubeseal
```
"features": {
    "ghcr.io/gickis/devcontainer-features/kubeseal:1": {
        "kubeseal": "latest"
    }
}
```
* kubeconform
```
"features": {
    "ghcr.io/gickis/devcontainer-features/kubeconform:1": {
        "kubeconform": "latest"
    },
}
```