#!/bin/bash

VKPR_HOME=~/.vkpr
VKPR_GLOBAL=$VKPR_HOME/global-values.yaml
VKPR_CONFIG=$VKPR_HOME/config

##ALL RESOURCES EXCEPT CERT-MANAGER MUST BE UNDER THIS NAMESPACE 
VKPR_K8S_NAMESPACE=vkpr

VKPR_GLAB=$VKPR_HOME/bin/glab
VKPR_K3D=$VKPR_HOME/bin/k3d
VKPR_ARKADE=$VKPR_HOME/bin/arkade
VKPR_KUBECTL=$VKPR_HOME/bin/kubectl
VKPR_HELM=$VKPR_HOME/bin/helm
VKPR_JQ=$VKPR_HOME/bin/jq
VKPR_YQ=$VKPR_HOME/bin/yq

export HELM_HOME=$VKPR_HOME/data/helm
VKPR_EXTERNAL_DNS_VERSION="0.9.0"
VKPR_WHOAMI_VERSION="2.5.0"
VKPR_KEYCLOAK_VERSION="5.1.2"