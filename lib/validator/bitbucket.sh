#!/bin/bash

# -----------------------------------------------------------------------------
# Bitbucket Credential validators
# -----------------------------------------------------------------------------

validateBitbucketToken() {
  if [[ "$1" =~ ^([A-Za-z0-9-]{24})$ ]]; then
    return
  else
    error "Invalid Bitbucket Access Token, fix the credential with the command."
    exit
  fi
}

validateBitbucketUsername() {
  if [[ "$1" =~ ^([A-Za-z0-9-]+)$ ]]; then
    return
  else
    error "Invalid Bitbucket Username, fix the credential with the command."
    exit
  fi
}