#!/usr/bin/env bash

if [ -n "$SFAPI_URL" ]; then
    echo "Using ${SFAPI_URL} to generate client"
else
    SFAPI_URL="https://api.nersc.gov/api/v1.2/openapi.json"
fi

if [ ! -f $PWD/openapi.json ]; then
    echo "Pulling from ${SFAPI_URL}"
    openapi-generator-cli generate -i ${SFAPI_URL} -g lua -o $PWD/generated --additional-properties packageName=sfapiclient
else
    echo "Using $PWD/openapi.json"
    openapi-generator-cli generate -i $PWD/openapi.json -g lua -o $PWD/generated --additional-properties packageName=sfapiclient
fi

python3 ./add_auth.py

cd $PWD/generated
luarocks make sfapiclient-1.0.0-1.rockspec
