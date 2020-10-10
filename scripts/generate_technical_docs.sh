#!/usr/bin/bash

# shellcheck disable=SC2034
npm_installed=$(npm -h > /dev/null 2>&1)
exit_code=$?

if [ ${exit_code} -eq 127 ]; then
    echo "ERROR: Node JS NPM package manager is not installed."
fi

ploc_installed=$(npm list ploc > /dev/null 2>&1)
exit_code=$?

if [ ${exit_code} -eq 1 ]; then
    echo "Installing PLOC - PL/SQL Code to Doc Converter:"
    npm install ploc
fi

echo "Generating technical documentation for PL/SQL:"

npm run build:all_docs
