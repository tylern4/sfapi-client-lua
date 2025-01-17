#!/usr/bin/env bash

if [ -n "$SFAPI_URL" ]; then
    echo "Using ${SFAPI_URL} to generate client"
else
    SFAPI_URL="https://api.nersc.gov/api/v1.2/openapi.json"
fi

openapi-generator-cli generate -i ${SFAPI_URL} -g lua -o $PWD/generated

python3 ./add_auth.py

cd $PWD/generated
luarocks make openapiclient-1.0.0-1.rockspec
