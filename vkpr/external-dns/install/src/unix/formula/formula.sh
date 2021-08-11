#!/bin/sh

runFormula() {
  echoColor "yellow" "Instalando external-dns..."
  VKPR_HOME=~/.vkpr
  VKPR_EXTERNAL_DNS_LOCAL=$VKPR_HOME/values/external-dns
  VKPR_EXTERNAL_DNS_VALUES=$VKPR_EXTERNAL_DNS_LOCAL/external-dns.yaml
  mkdir -p $VKPR_EXTERNAL_DNS_LOCAL

  add_repo_external_dns
  install_external_dns
}

add_repo_external_dns() {
  $VKPR_HOME/bin/helm repo add bitnami https://charts.bitnami.com/bitnami
  $VKPR_HOME/bin/helm repo update
}

install_external_dns() {
  export DO_AUTH_TOKEN=$INPUT_DIGITAL_OCEAN
  if [[ ! -e $VKPR_EXTERNAL_DNS_VALUES ]]; then
    . $(dirname "$0")/utils/external-dns.sh $DO_AUTH_TOKEN $VKPR_EXTERNAL_DNS_VALUES
  fi
  $VKPR_HOME/bin/helm upgrade -i vkpr -f $VKPR_EXTERNAL_DNS_VALUES bitnami/external-dns
}

echoColor() {
  case $1 in
    red)
      echo "$(printf '\033[31m')$2$(printf '\033[0m')"
      ;;
    green)
      echo "$(printf '\033[32m')$2$(printf '\033[0m')"
      ;;
    yellow)
      echo "$(printf '\033[33m')$2$(printf '\033[0m')"
      ;;
    blue)
      echo "$(printf '\033[34m')$2$(printf '\033[0m')"
      ;;
    cyan)
      echo "$(printf '\033[36m')$2$(printf '\033[0m')"
      ;;
    esac
}