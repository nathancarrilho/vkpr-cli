#!/bin/sh

runFormula() {
  checkGlobalConfig $DOMAIN "localhost" "domain" "DOMAIN"
  checkGlobalConfig $SECURE "false" "secure" "SECURE"
  checkGlobalConfig $ALERTMANAGER "false" "prometheusstack.alertmanager" "PROMETHEUS_ALERT_MANAGER"
  
  local VKPR_ENV_GRAFANA_DOMAIN="grafana.${VKPR_ENV_DOMAIN}"
  local VKPR_ENV_ALERT_MANAGER_DOMAIN="alertmanager.${VKPR_ENV_DOMAIN}"

  addRepoPrometheusStack
  installPrometheusStack
}


addRepoPrometheusStack() {
  $VKPR_HELM repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
}

installPrometheusStack() {
  echoColor "yellow" "Installing prometheus stack..."
  local VKPR_PROMETHEUS_VALUES=$(dirname "$0")/utils/prometheus.yaml
  local YQ_VALUES='.grafana.ingress.hosts[0] = "'$VKPR_ENV_GRAFANA_DOMAIN'" | .grafana.ingress.hosts style = "double" | .grafana.adminPassword = "'$GRAFANA_PASSWORD'"'
  settingStack
  $VKPR_YQ eval "$YQ_VALUES" "$VKPR_PROMETHEUS_VALUES" \
  | $VKPR_HELM upgrade -i -f - vkpr-prometheus-stack prometheus-community/kube-prometheus-stack
}

settingStack() {
  if [[ $VKPR_ENV_PROMETHEUS_ALERT_MANAGER = true ]]; then
    YQ_VALUES=''$YQ_VALUES' |
      .alertmanager.enabled = true |
      .alertmanager.ingress.enabled = true |
      .alertmanager.ingress.hosts[0] = "'$VKPR_ENV_ALERT_MANAGER_DOMAIN'"
    '
  fi
  if [[ $(existLoki) = "true" ]]; then
    YQ_VALUES=''$YQ_VALUES' |
      .grafana.additionalDataSources[0].name = "Loki" |
      .grafana.additionalDataSources[0].type = "loki" |
      .grafana.additionalDataSources[0].url = "http://vkpr-loki-stack:3100" |
      .grafana.additionalDataSources[0].access = "proxy" |
      .grafana.additionalDataSources[0].basicAuth = false |
      .grafana.additionalDataSources[0].editable = true
    '
  fi
  if [[ $VKPR_ENV_SECURE = true ]]; then
    YQ_VALUES=''$YQ_VALUES' |
      .grafana.ingress.annotations.["'kubernetes.io/tls-acme'"] = "'true'" |
      .grafana.ingress.tls[0].hosts[0] = "'$VKPR_ENV_GRAFANA_DOMAIN'" |
      .grafana.ingress.tls[0].secretName = "'grafana-cert'"
    '
    if [[ $VKPR_ENV_PROMETHEUS_ALERT_MANAGER = true ]]; then
      YQ_VALUES=''$YQ_VALUES' |
        .alertmanager.ingress.annotations.["'kubernetes.io/tls-acme'"] = "'true'" |
        .alertmanager.ingress.tls[0].hosts[0] = "'$VKPR_ENV_ALERT_MANAGER_DOMAIN'" |
        .alertmanager.ingress.tls[0].secretName = "'alertmanager-cert'"
      '
    fi
  fi
}

existLoki() {
  local EXISTING_LOKI=$($VKPR_KUBECTL get pod vkpr-loki-stack-0 -o name --ignore-not-found | cut -d "/" -f 2)
  if [[ $EXISTING_LOKI = "vkpr-loki-stack-0" ]]; then
    echo "true"
    return
  fi
  echo "false"
}
