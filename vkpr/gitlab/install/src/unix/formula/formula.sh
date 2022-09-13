#!/usr/bin/env bash

runFormula() {
  local VKPR_GITLAB_VALUES HELM_ARGS;
  formulaInputs
  validateInputs

  VKPR_GITLAB_VALUES=$(dirname "$0")/utils/gitlab.yaml

  startInfos
  settingGitlab
  [ $DRY_RUN = false ] && registerHelmRepository gitlab http://charts.gitlab.io/
  ## Add the version of the application in vkpr-cli/lib/versions.sh
  installApplication "gitlab" "gitlab/gitlab" "$VKPR_ENV_GITLAB_NAMESPACE" "$VKPR_GITLAB_VERSION" "$VKPR_GITLAB_VALUES" "$HELM_ARGS"
}

## Add here some usefull info about the formula
startInfos() {
  bold "=============================="
  boldInfo "VKPR Gitlab Install Routine"
  boldNotice "Domain: $VKPR_ENV_GLOBAL_DOMAIN"
  boldNotice "Secure: $VKPR_ENV_GLOBAL_SECURE"
  boldNotice "Namespace: $VKPR_ENV_GITLAB_NAMESPACE"
  boldNotice "Ingress Controller: $VKPR_ENV_GITLAB_INGRESS_CLASS_NAME"
  bold "=============================="
}

## Add here values that can be used by the globals (env, vkpr values, input...)
formulaInputs() {
  checkGlobalConfig "$VKPR_ENV_GLOBAL_NAMESPACE" "$VKPR_ENV_GLOBAL_NAMESPACE" "gitlab.namespace" "GITLAB_NAMESPACE"
  checkGlobalConfig "$VKPR_ENV_GLOBAL_INGRESS_CLASS_NAME" "$VKPR_ENV_GLOBAL_INGRESS_CLASS_NAME" "gitlab.ingressClassName" "GITLAB_INGRESS_CLASS_NAME"
  checkGlobalConfig "$SSL" "false" "gitlab.ssl.enabled" "GITLAB_SSL"
  checkGlobalConfig "$CRT_FILE" "" "gitlab.ssl.crt" "GITLAB_SSL_CERTIFICATE"
  checkGlobalConfig "$KEY_FILE" "" "gitlab.ssl.key" "GITLAB_SSL_KEY"
  checkGlobalConfig "" "" "gitlab.ssl.secretName" "GITLAB_SSL_SECRET"
}

## Add here the validators from the inputs
validateInputs() {
  validateGitlabDomain "$VKPR_ENV_GLOBAL_DOMAIN"
  validateGitlabSecure "$VKPR_ENV_GLOBAL_SECURE"
  validateGitlabIngressClassName "$VKPR_ENV_GITLAB_INGRESS_CLASS_NAME"
  validateGitlabNamespace "$VKPR_ENV_GITLAB_NAMESPACE"

  validateGitlabSsl "$VKPR_ENV_GITLAB_SSL"
  if [[ "$VKPR_ENV_GITLAB_SSL" == true  ]] ; then
    validateGitlabSslCrt "$VKPR_ENV_GITLAB_SSL_CERTIFICATE"
    validateGitlabSslKey "$VKPR_ENV_GITLAB_SSL_KEY"
  fi
}

# Add here a configuration of application
settingGitlab() {
    YQ_VALUES=".server.ingress.hosts[0] = \"$VKPR_ENV_GITLAB_DOMAIN\" |
    .server.config.url = \"$VKPR_ENV_GITLAB_DOMAIN\" |
    .server.ingress.annotations.[\"kubernetes.io/ingress.class\"] = \"$VKPR_ENV_GITLAB_INGRESS_CLASS_NAME\"
  "

  if [[ "$VKPR_ENV_GLOBAL_SECURE" == true ]]; then
    YQ_VALUES="$YQ_VALUES |
      .server.ingress.annotations.[\"kubernetes.io/tls-acme\"] = \"true\" |
      .server.ingress.tls[0].secretName = \"gitlab-cert\" |
      .server.ingress.tls[0].hosts[0] = \"$VKPR_ENV_GITLAB_DOMAIN\" |
      .server.ingress.https = true
    "
  fi

    if [[ "$VKPR_ENV_GITLAB_SSL" == "true" ]]; then
    if [[ "$VKPR_ENV_GITLAB_SSL_SECRET" == "" ]]; then
      VKPR_ENV_GITLAB_SSL_SECRET="gitlab-certificate"
      $VKPR_KUBECTL create secret tls $VKPR_ENV_GITLAB_SSL_SECRET -n "$VKPR_ENV_GITLAB_NAMESPACE" \
        --cert="$VKPR_ENV_GITLAB_SSL_CERTIFICATE" \
        --key="$VKPR_ENV_GITLAB_SSL_KEY"
    fi
    YQ_VALUES="$YQ_VALUES |
      .server.ingress.tls[0].hosts[0] = \"$VKPR_ENV_GITLAB_DOMAIN\" |
      .server.ingress.tls[0].secretName = \"$VKPR_ENV_GITLAB_SSL_SECRET\"
     "
  fi
  
  # YQ_VALUES=".server.ingress.hosts[0] = \"$VKPR_ENV_GITLAB_DOMAIN\" |
  #   .server.config.url = \"$VKPR_ENV_GITLAB_DOMAIN\" |
  #   .server.ingress.annotations.[\"kubernetes.io/ingress.class\"] = \"$VKPR_ENV_GITLAB_INGRESS_CLASS_NAME\"
  # "

  # if [[ "$VKPR_ENV_GLOBAL_SECURE" == true ]]; then
  #   YQ_VALUES="$YQ_VALUES |
  #     .server.ingress.annotations.[\"kubernetes.io/tls-acme\"] = \"true\" |
  #     .server.ingress.tls[0].secretName = \"gitlab-cert\" |
  #     .server.ingress.tls[0].hosts[0] = \"$VKPR_ENV_GITLAB_DOMAIN\" |
  #     .server.ingress.https = true
  #   "
  # fi

  #   if [[ "$VKPR_ENV_GITLAB_SSL" == "true" ]]; then
  #   if [[ "$VKPR_ENV_GITLAB_SSL_SECRET" == "" ]]; then
  #     VKPR_ENV_GITLAB_SSL_SECRET="gitlab-certificate"
  #     $VKPR_KUBECTL create secret tls $VKPR_ENV_GITLAB_SSL_SECRET -n "$VKPR_ENV_GITLAB_NAMESPACE" \
  #       --cert="$VKPR_ENV_GITLAB_SSL_CERTIFICATE" \
  #       --key="$VKPR_ENV_GITLAB_SSL_KEY"
  #   fi
  #   YQ_VALUES="$YQ_VALUES |
  #     .server.ingress.tls[0].hosts[0] = \"$VKPR_ENV_GITLAB_DOMAIN\" |
  #     .server.ingress.tls[0].secretName = \"$VKPR_ENV_GITLAB_SSL_SECRET\"
  #    "
  # fi

  settingGitlabEnvironment

  debug "YQ_CONTENT = $YQ_VALUES"
}

# Add here a configuration of application in specific envs
settingGitlabEnvironment() {
  if [[ "$VKPR_ENVIRONMENT" == "okteto" ]]; then
    HELM_ARGS="--cleanup-on-fail"
    YQ_VALUES="$YQ_VALUES"
  fi
}
