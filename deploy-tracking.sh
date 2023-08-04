#!/bin/bash
PIPE_DEEPLINK=$1
RELEASEV=$2 #service release version
APIKEY_NR=$3 # NR api key Ref: https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/
COMMIT=$4 # commit hash
CHANGELOG=$5  # changes involved in this release, any link to a changelog document is ok, also you can use the commit message from your scm using something like: `git log --format=%B --oneline -n 1 $GITLAB_COMMIT_MSG | sed -e 's/^\w*\ *//'`
USERNAME=$6 # user name that triggers this deploy, get it from your pipeline
PIPE_DEEPLINK=$7 # here im using pipeline execution link.
DESC="$USERNAME deployed revision $RELEASEV" #any relevant description
NR_APP=$(yq '.common.app_name' $ENVIRONMENT/newrelic.yml) #reading app name on newrelic from apm agent config file
echo "getting UUID for $NR_APP"
echo "version is $RELEASEV"
NR_HEADERS=(-H "X-API-KEY: $APIKEY_NR" -H "Content-Type: application/json")
cat << EOF > ./data.dat
{"query":"{\n  actor {\n    entitySearch(queryBuilder: {name: \"$NR_APP\", domain: APM, type: APPLICATION}) {\n      count\n      query\n      results {\n        entities {\n          guid\n        name\n        }\n      }\n    }\n  }\n}\n", "variables":""}
EOF

#first, we need to get new relic application guid, using nr app name

NRGUID=$(curl https://api.newrelic.com/graphql \
"${NR_HEADERS[@]}" \
--data-binary @data.dat | jq '.data.actor.entitySearch.results.entities[] | select(.name == "'$NR_APP'" ).guid' | sed 's/"//g')
echo "new relic guid for $NR_APP is: $NRGUID "

#Create a new Deployment for the previously guid

cat << EOF > data.dat
{"query":"mutation {\n  changeTrackingCreateDeployment(deployment: {version: \"$RELEASEV\", entityGuid: \"$NRGUID\", commit: \"$COMMIT\", changelog: \"$CHANGELOG\", description: \"$DESC\", user: \"$USERNAME\", deploymentType: ROLLING, deepLink: \"$PIPE_DEEPLINK\"}) {\n    deploymentId\n    entityGuid\n    commit\n    changelog\n    user\n    description\n        deploymentType\n    deepLink\n  }\n}\n", "variables":""}
EOF
curl https://api.newrelic.com/graphql \
"${NR_HEADERS[@]}" \
--data-binary @data.dat
rm data.dat
