#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Gitlab Credential validators
# -----------------------------------------------------------------------------

validateGitlabDomain (){
  if  $(validateDomain $1); then
    return
  else
    error "The value used for VKPR_ENV_GLOBAL_DOMAIN \"$1\" is invalid:  the VKPR_ENV_GLOBAL_DOMAIN must consist of a lower case alphanumeric  characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example-vkpr.com', regex used for validation is ^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9].)+([a-zA-Z]{2,})|localhost$)"
    exit
  fi
}

validateGitlabSecure(){
  if $(validateBool $1); then
    return
  else
    error "The value used for VKPR_ENV_GLOBAL_SECURE \"$1\" is invalid:  the VKPR_ENV_GLOBAL_SECURE must consist of a boolean value."
    exit
  fi
}
validateGitlabNamespace (){
  if [[ "$1" =~ ^([A-Za-z0-9-]+)$ ]]; then
    return
  else
    error "The value used for VKPR_ENV_GITLAB_NAMESPACE \"$1\" is invalid: VKPR_ENV_GITLAB_NAMESPACE must consist of lowercase, uppercase or '-' alphanumeric characters, (e.g. 'gitlab', regex used for validation is ^([A-Za-z0-9-]+)$)"
    exit
  fi
}

validateGitlabIngressClassName (){
  if [[ "$1" =~ ^([a-z]+)$ ]]; then
    return
  else
    error "The value used for VKPR_ENV_GITLAB_INGRESS_CLASS_NAME \"$1\" is invalid: VKPR_ENV_GITLAB_INGRESS_CLASS_NAME must consist of lowercase alphanumeric characters, (e.g. 'nginx', regex used for validation is ^([a-z]+)$)"
    exit
  fi
}

validateGitlabSsl (){
  if $(validateBool $1); then
    return
  else
    error "The value used for VKPR_ENV_GITLAB_SLL \"$1\" is invalid:  the VKPR_ENV_GITLAB_SSL must consist of a boolean value."
    exit
  fi
}

validateGitlabSslCrt (){
  if $(validatePath $1); then
    return
  else
    error "The value used for VKPR_ENV_GITLAB_SSL_CERTIFICATE \"$1\" is invalid: VKPR_ENV_GITLAB_SSL_CERTIFICATE must consist of lowercase, uppercase or '-' alphanumeric characters, (e.g. '/tmp/certificate.crt', regex used for validation is ^(\/[^\/]+){1,}\/?$)"
    exit
  fi
}

validateGitlabSslKey (){
  if $(validatePath $1); then
    return
  else
    error "The value used for VKPR_ENV_GITLAB_SSL_KEY \"$1\" is invalid: VKPR_ENV_GITLAB_SSL_KEY must consist of lowercase, uppercase or '-' alphanumeric characters, (e.g. '/tmp/certificate.key', regex used for validation is ^(\/[^\/]+){1,}\/?$)"
    exit
  fi
}

validateGitlabSecretName(){
  if [[ $1 =~ ^([A-Za-z0-9-])$ ]]; then
    return
  else
    error "The value used for VKPR_ENV_GITLAB_SSL_SECRET \"$1\" is invalid: VKPR_ENV_GITLAB_SSL_SECRET must consist of lowercase, uppercase or alphanumeric characters, (e.g. 'gitlab', regex used for validation is ^([A-Za-z0-9-])$)"
    exit
  fi
}

validateGitlabToken() {
  if [[ "$1" =~ ^([A-Za-z0-9-]{26})$ ]]; then
    return
    else
    error "The value used for GITLAB_TOKEN \"$1\" is invalid: GITLAB_TOKEN must consist of lowercase, uppercase or '-' alphanumeric characters, (e.g. 'Aa1Bb2Cc3Dd4Ee5Ff6Gg7Hh8Ii', regex used for validation is ^([A-Za-z0-9-]{26})$."
    exit
  fi
}

validateGitlabUsername() {
  if [[ "$1" =~ ^([A-Za-z0-9-]+)$ ]]; then
    return
    else
    error "The value used for GITLAB_USERNAME \"$1\" is invalid: GITLAB_USERNAME must consist of lowercase, uppercase or '-' alphanumeric characters, (e.g. 'gitlab', regex used for validation is ^([A-Za-z0-9-]+)$."
    exit
  fi
}
