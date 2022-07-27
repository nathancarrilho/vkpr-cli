#!/bin/bash

runFormula() {
  info "Creating new secret ${PARAMETER_NAME}"
  setCredentials
  validateInputs

  ## seting '*' as default value for PARAMETER_SCOPE
  bitbucketCreateOrUpdateRepositoryVariable "$PROJECT_NAME" "$PARAMETER_NAME" "$PARAMETER_VALUE" "$PARAMETER_MASKED" "$BITBUCKET_USERNAME" "$BITBUCKET_TOKEN"
  debug "TOKEN: $BITBUCKET_TOKEN"
}

setCredentials() {
  BITBUCKET_TOKEN=$($VKPR_JQ -r .credential.bitbucket.token "$VKPR_CREDENTIAL"/bitbucket)
  BITBUCKET_USERNAME=$($VKPR_JQ -r .credential.bitbucket.username "$VKPR_CREDENTIAL"/bitbucket)
}

validateInputs(){
  validateBitbucketToken "$BITBUCKET_TOKEN"
  validateBitbucketUsername "$BITBUCKET_USERNAME"
}