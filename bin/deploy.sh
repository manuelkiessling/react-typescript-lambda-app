#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ ! -s "$HOME/.nvm/nvm.sh" ]
then
  if [ ! -x /opt/homebrew/bin/brew ] || [ ! -s "$(/opt/homebrew/bin/brew --prefix)/opt/nvm/nvm.sh" ]
  then
    echo "This script requires a working NVM installation."
    exit 1
  fi
fi

[ -s "$HOME/.nvm/nvm.sh" ] && source "$HOME/.nvm/nvm.sh"
[ -x /opt/homebrew/bin/brew ] && [ -s "$(/opt/homebrew/bin/brew --prefix)/opt/nvm/nvm.sh" ] && source "$(/opt/homebrew/bin/brew --prefix)/opt/nvm/nvm.sh"

DEPLOYMENT_NUMBER="$(date -u +%FT%TZ)"
echo "$DEPLOYMENT_NUMBER" > "$DIR/../deployment_number"

PROJECT_NAME="$(cat "$DIR/../infrastructure/variables.tf" | grep 'project_name' -A 2 | grep 'default' | cut -d '=' -f 2 | cut -d '"' -f 2)"

pushd "$DIR/../frontend"
  rm -rf build
  nvm install
  nvm use
  npm i --no-save
  npm run build
  aws s3 cp --recursive --acl public-read build/ "s3://$PROJECT_NAME-frontend/"
popd

[ "$1" == "frontend" ] && exit 0

pushd "$DIR/../backend/"
  rm -rf build
  rm -rf node_modules
  nvm install
  nvm use
  npm i --target_arch=x64 --target_platform=linux --target_libc=glibc --no-save
  npm run build
  pushd build
    zip -r rest_api.zip ./
    aws s3 cp ./rest_api.zip "s3://$PROJECT_NAME-backend/$DEPLOYMENT_NUMBER/"
  popd
popd

pushd "$DIR/../infrastructure"
  terraform init
  terraform apply -auto-approve -var deployment_number="$DEPLOYMENT_NUMBER"
popd
