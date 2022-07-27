#!/bin/bash

runFormula() {
  PROJECT_ID=$(rawUrlEncode "${PROJECT_NAME}")
  notice "Creating new parameter ${PARAMETER_NAME}"
  setCredentials
  validateInputs
  
  ## seting '*' as default value for PARAMETER_SCOPE
  createOrUpdateVariable "$PROJECT_ID" "$PARAMETER_NAME" "$PARAMETER_VALUE" "$PARAMETER_MASKED" "${PARAMETER_SCOPE:-\*}" "$GITLAB_TOKEN"
}

setCredentials() {
  GITLAB_USERNAME=$($VKPR_JQ -r .credential.gitlab.username "$VKPR_CREDENTIAL"/gitlab)
  GITLAB_TOKEN=$($VKPR_JQ -r .credential.gitlab.token "$VKPR_CREDENTIAL"/gitlab)
}

validateInputs(){
  validateGitlabUsername "$GITLAB_USERNAME"
  validateGitlabToken "$GITLAB_TOKEN"
}