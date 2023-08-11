#!/bin/bash

mkdir -p ./support_bundle/log

supervisorctl status >> ./support_bundle/supervisorctl.log

cp -r /var/log/akeyless/. ./support_bundle/log

ADMIN_ACCESS_KEY=secret ADMIN_PASSWORD=secret ADMIN_CERTIFICATE_KEY=secret REDIS_PASS=secret env >> ./support_bundle/environment.log

CRITICAL_SERVICE_CONNECTIVITY_MISSING=false

# For a single-tenant environment you should use 
# the sub-domain like this:
# AKEYLESS_DOMAIN=".mycorp.akeyless.io"
AKEYLESS_DOMAIN=${AKEYLESS_DOMAIN:-".akeyless.io"}

declare -a akeyless_urls=(
    "https://vault${AKEYLESS_DOMAIN}/status"
    "https://auth${AKEYLESS_DOMAIN}/status"
    "https://audit${AKEYLESS_DOMAIN}/status"
    "https://bis${AKEYLESS_DOMAIN}/status"
    "https://gator${AKEYLESS_DOMAIN}/status"
    "https://kfm1${AKEYLESS_DOMAIN}/status"
    "https://kfm2${AKEYLESS_DOMAIN}/status"
    "https://kfm3${AKEYLESS_DOMAIN}/status"
    "https://kfm4${AKEYLESS_DOMAIN}/status"
    "https://vault-ro${AKEYLESS_DOMAIN}/status"
    "https://auth-ro${AKEYLESS_DOMAIN}/status"
    "https://audit-ro${AKEYLESS_DOMAIN}/status"
    "https://bis-ro${AKEYLESS_DOMAIN}/status"
    "https://gator-ro${AKEYLESS_DOMAIN}/status"
    "https://kfm1-ro${AKEYLESS_DOMAIN}/status"
    "https://kfm2-ro${AKEYLESS_DOMAIN}/status"
    "https://kfm3-ro${AKEYLESS_DOMAIN}/status"
    "https://kfm4-ro${AKEYLESS_DOMAIN}/status"
)

declare -a legacy_akeyless_or_other_urls=(
    "https://rest${AKEYLESS_DOMAIN}"
    "https://akeyless-cli.s3.us-east-2.amazonaws.com"
    "https://akeylessservices.s3.us-east-2.amazonaws.com"
    "https://sqs.us-east-2.amazonaws.com"
)

for url in "${akeyless_urls[@]}"
do
    if curl -sSf $url > /dev/null; then
        echo "Akeyless Service is up and running and reachable : $url" >> ./support_bundle/connectivity_check.log
    else
        echo "Akeyless Service is NOT reachable : $url" >> ./support_bundle/connectivity_check.log
        CRITICAL_SERVICE_CONNECTIVITY_MISSING=true
    fi
done

for url in "${legacy_akeyless_or_other_urls[@]}"
do
    INITIAL_RESULT=$(curl -LI $url -o /dev/null -w '%{http_code}\n' -s)
    RESULT=$(( $INITIAL_RESULT + 0 ))
    case $RESULT in
        200 | 403 | 404 | 405)
            echo "Akeyless dependandant service is up and running and reachable : $url" >> ./support_bundle/connectivity_check.log
            ;;

        *)
            echo "Akeyless dependandant service is NOT reachable (Status Code : ${RESULT}) : $url" >> ./support_bundle/connectivity_check.log
            CRITICAL_SERVICE_CONNECTIVITY_MISSING=true
            ;;
    esac
done

tar -czvf support_bundle.tar.gz ./support_bundle