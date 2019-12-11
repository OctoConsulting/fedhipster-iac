### The invokeScrape.sh script will loop throught the csv file provided as parm #1
###   and for each line invoke the scraper (using key-cloaks OAUTH authentication)
##    based on parms #2 and #3


Usage: invokeScrape.sh: <Input URL File> <KeyCloak Server> <App Gateway> <Sleep Time (secs)>

## To Invoke this, run the following
./invokeScrape.sh OneTimeDataSourceUrlLoad_WIKI.csv localhost:9080 localhost:8080 5
${INVOKE_PATH}/invokeScrape.sh ${INVOKE_PATH}/OneTimeDataSourceUrlLoad_WIKI.csv localhost:9080 localhost:8080 5
