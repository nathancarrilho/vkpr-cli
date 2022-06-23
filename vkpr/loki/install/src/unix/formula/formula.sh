#!/bin/bash

runFormula() {
  # Global values
  checkGlobalConfig "$DOMAIN" "localhost" "global.domain" "GLOBAL_DOMAIN"
  checkGlobalConfig "$VKPR_K8S_NAMESPACE" "vkpr" "global.namespace" "GLOBAL_NAMESPACE"
  
  # App values
  checkGlobalConfig "false" "false" "loki.metrics" "LOKI_METRICS"
  checkGlobalConfig "false" "false" "loki.persistence" "LOKI_PERSISTANCE"
  checkGlobalConfig "$VKPR_ENV_GLOBAL_NAMESPACE" "$VKPR_ENV_GLOBAL_NAMESPACE" "loki.namespace" "LOKI_NAMESPACE"

  # External app values
  checkGlobalConfig "$VKPR_ENV_GLOBAL_NAMESPACE" "$VKPR_ENV_GLOBAL_NAMESPACE" "prometheus-stack.namespace" "GRAFANA_NAMESPACE"

  local VKPR_LOKI_VALUES; VKPR_LOKI_VALUES=$(dirname "$0")/utils/loki.yaml

  startInfos
  addRepLoki
  installLoki
}

startInfos() {
  echo "=============================="
  info "VKPR Loki Install Routine"
  echo "=============================="
}

addRepLoki(){
  registerHelmRepository grafana https://grafana.github.io/helm-charts
}

installLoki(){
  local YQ_VALUES=".grafana.enabled = false"
  settingLoki

  if [[ $DRY_RUN == true ]]; then
    echoColor "bold" "---"
    mergeVkprValuesHelmArgs "loki" "$VKPR_LOKI_VALUES"
    $VKPR_YQ eval "$YQ_VALUES" "$VKPR_LOKI_VALUES"    
  else
    info "Installing Loki..."
    $VKPR_YQ eval -i "$YQ_VALUES" "$VKPR_LOKI_VALUES"
    mergeVkprValuesHelmArgs "loki" "$VKPR_LOKI_VALUES"
    $VKPR_HELM upgrade -i --version "$VKPR_LOKI_VERSION" \
      --namespace "$VKPR_ENV_LOKI_NAMESPACE" --create-namespace \
      --wait -f "$VKPR_LOKI_VALUES" loki-stack grafana/loki-stack
    existGrafana
  fi
}

settingLoki() {
  if [[ "$VKPR_ENV_LOKI_METRICS" == true ]]; then
    YQ_VALUES="$YQ_VALUES |
      .loki.serviceMonitor.enabled = true |
      .loki.serviceMonitor.interval = \"30s\" |
      .loki.serviceMonitor.additionalLabels.release = \"prometheus-stack\" |
      .loki.serviceMonitor.scrapeTimeout = \"30s\"
    "
  fi

  if [[ "$VKPR_ENV_LOKI_PERSISTANCE" == true ]]; then
    YQ_VALUES="$YQ_VALUES |
      .loki.persistence.enabled = true |
      .loki.persistence.accessModes[0] = \"ReadWriteOnce\" |
      .loki.persistence.size = \"8Gi\"
    "
  fi
}

existGrafana() {
  if [[ $(checkPodName "$VKPR_ENV_GRAFANA_NAMESPACE" "prometheus-stack-grafana") == "true" ]]; then
    local LOGINGRAFANA TOKEN_API_GRAFANA
    LOGINGRAFANA="$($VKPR_KUBECTL get secret --namespace "$VKPR_ENV_GRAFANA_NAMESPACE" prometheus-stack-grafana -o yaml |\
                    $VKPR_YQ eval '.data.admin-user' - | base64 -d):$($VKPR_KUBECTL get secret --namespace "$VKPR_ENV_GRAFANA_NAMESPACE" prometheus-stack-grafana -o yaml | $VKPR_YQ eval '.data.admin-password' - | base64 -d)"

    TOKEN_API_GRAFANA=$(curl -skX POST \
      -H "Host: grafana.${VKPR_ENV_GLOBAL_DOMAIN}" -H "Content-Type: application/json" \
      -d '{"name": "apikeycurl'$RANDOM'","role": "Admin", "secondsToLive": 60}' \
      http://"$LOGINGRAFANA"@127.0.0.1:8000/api/auth/keys | $VKPR_JQ --raw-output '.key' -
    )

    if [[ $TOKEN_API_GRAFANA == "" ]]; then
      error "Ingress is not installed to generate the api token"
      return
    fi

    EXIST_LOKI_DATASOURCE=$(curl -skX GET \
      -H "Host: grafana.${VKPR_ENV_GLOBAL_DOMAIN}" -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN_API_GRAFANA" \
      http://127.0.0.1:8000/api/datasources/name/loki
    )

    if [[ $EXIST_LOKI_DATASOURCE == "{\"message\":\"Data source not found\"}" ]]; then
      curl -sK -X \
      -H "Host: grafana.$VKPR_ENV_GLOBAL_DOMAIN" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN_API_GRAFANA" \
      -d '{
            "name":"loki",
            "type":"loki",
            "url":"loki-stack.'"$VKPR_ENV_LOKI_NAMESPACE"'.svc.cluster.local:3100",
            "access":"proxy",
            "basicAuth":false,
            "editable": true
          }' http://127.0.0.1:8000/api/datasources > /dev/null && info "Loki Datasource Added"
      else
      warn "Loki Datasource already created"
    fi
  fi
}
