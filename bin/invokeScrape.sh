#!/bin/bash
#set -x

##  DEBUG true will output msgs to consoleDEBUG=true
#DEBUG=true
DEBUG=false
export KUBECONFIG=../kubeconfig
kubectl apply -f ../config_map_aws_auth.yaml
###########################################
###########################################
##  This script will read scraper data from
##   <input file> and for URL will invoke
##  the contect scraper to pull data
###########################################
###########################################
## Parameters
##  1  Source Input File
##  2  Environment
##  3  Time (in secs) between scrapes
##  4  Wait (in mins) until first scrape
##

if [[ ! ("$#" == 4) ]]; then
    echo "Usage: $(basename $0): <Input URL File> <environment> <Sleep Time (secs)> <First scrape delay (mins)>"
    exit 1;
fi
PARM_URL_FILE=${1}
#PARM_HOST_KEYCLOAK=${2}
#PARM_HOST_SCRAPER=${3}
PARM_ENV=${2}
PARM_SLEEP_TIME_SECS=${3}
PARM_MINS_FIRST_SCRAPE=${4}

PARM_HOST_SCRAPER=$(kubectl -n $PARM_ENV get svc/retrospider-app -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
for i in {1..10}
do
  if [ -z $PARM_HOST_SCRAPER ]; then
    sleep 5
    PARM_HOST_SCRAPER=$(kubectl -n $PARM_ENV get svc/retrospider-app -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
  else
    break
  fi
done
PARM_HOST_KEYCLOAK=$(kubectl -n $PARM_ENV get svc/keycloak -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
for i in {1..10}
do
  if [ -z $PARM_HOST_KEYCLOAK ]; then
    sleep 5
    PARM_HOST_KEYCLOAK=$(kubectl -n $PARM_ENV get svc/keycloak -o json | grep hostname | sed 's|.*: \(.*\)|\1|;s/"//g')
  else
    break
  fi
done

SCRAPER_HOST="http://${PARM_HOST_SCRAPER}:8080"
## Sleep displaying count down timer for first scrape
echo "INFO: Scheduling Scraper for host: ${SCRAPER_HOST} in ${PARM_MINS_FIRST_SCRAPE} minutes       \r"
WAIT_SECS=$(($PARM_MINS_FIRST_SCRAPE*60))
sleep $WAIT_SECS

if [[ ! -r "${PARM_URL_FILE}" ]]; then
    echo "ERROR: ${PARM_URL_FILE} does not exist or is not readable. Exiting..."
    exit 2;
fi


SLEEP_TIME_SECS_DEFAULT=120

## Can be used if the SleepTime parater is not passed in as a default
if [[ -z ${PARM_SLEEP_TIME_SECS} ]]; then
    PARM_SLEEP_TIME_SECS=${SLEEP_TIME_SECS_DEFAULT}
fi


CURL="curl"
CURL_METHOD_POST="-X POST"
CURL_PARMS="-H 'Content-Type: application/x-www-form-urlencoded'"
CURL_PARMS_VERBOSE="-s"
#CURL_PARMS_VERBOSE=""

KEYCLOAK_USER=web_app
KEYCLOAK_PSWD=web_app

OAUTH_HOST="http://${PARM_HOST_KEYCLOAK}:9080"
OAUTH_API="/auth/realms/jhipster/protocol/openid-connect/token"

APP_USER=admin
APP_PSWD=admin

SCRAPER_API="/api/dossier-contents"
SCAPER_CURL_PARMS="-H 'Content-Type: application/json'"
SCRAPER_TOKEN="-H 'Authorization: Bearer __BEARER_TOKEN__'"

counter=1
while IFS= read -r line;do
    source=$(echo ${line} | cut -d'|' -f1)
    url=$(echo ${line} | cut -d'|' -f3)
    SCRAPER_DATA="{\"sourceName\": \"__SOURCE_SITE_NAME__\",\"sourceUrl\": \"__SCRAPER_SITE_URL__\",\"sourceDate\": \"__SCRAPER_DATE__\"}"

    if [[ "${source}" = "WIKI" ]]; then
        #echo "${source} :: ${url}"

        ## Get a new Access Token from keycloak server
        ## Note: this is good for about five minutes

        ACCESS_TOKEN=$(${CURL} ${CURL_PARMS_VERBOSE} ${CURL_METHOD_POST} -u ${KEYCLOAK_USER}:${KEYCLOAK_PSWD} -d 'grant_type=password&username=admin&password=admin' ${OAUTH_HOST}${OAUTH_API} | jq -r '.access_token')
        #echo "AccessToken: ${ACCESS_TOKEN}"
        if [[ ${ACCESS_TOKEN} == "null" ]]; then
            echo "ERROR: Could not get access token:"
            exit 3
        fi

	## Format data json
        SCRAPER_DATA=$(echo ${SCRAPER_DATA} | sed "s|__SCRAPER_SITE_URL__|${url}|")
        SCRAPER_DATA=$(echo ${SCRAPER_DATA} | sed "s|__SOURCE_SITE_NAME__|${source}|")

        ## Format time to be 2019-08-15T01:05:26.367Z  YYYY-MM-DDTHH24:MM:SS.mmmZ  (i.e. 2019-08-15T01:05:26.367Z)
        SCRAPER_DATE_CURRENT="$(date -u "+%FT%T.")$(printf '%03dZ' ${counter})"
        SCRAPER_DATA=$(echo ${SCRAPER_DATA} | sed "s|__SCRAPER_DATE__|${SCRAPER_DATE_CURRENT}|")

        CURL_RESPONSE=$(curl -s -X POST ${SCRAPER_HOST}/api/dossier-contents -H 'Content-Type: application/json' -H 'cache-control: no-cache' -H "Authorization: Bearer ${ACCESS_TOKEN}" -d "${SCRAPER_DATA}")
        ScraperRC=$?

        echo "SC: ${counter}: Invoking scraper for: ${source}: Status: ${ScraperRC}: ${CURL_RESPONSE}: ${url}"
        let counter++
    fi

    ## Sleep displaying count down timer
    for s in $(seq ${PARM_SLEEP_TIME_SECS} -1 1); do
        [[ ${DEBUG} = true ]] && echo -ne "Next scrape in ${s} secs      \r"
        sleep 1
    done

done < ${PARM_URL_FILE}

echo "INFO: Fininshed Invoking Scraper:  ${counter} sites for scrapper host: ${SCRAPER_HOST}     \r"
exit 0
