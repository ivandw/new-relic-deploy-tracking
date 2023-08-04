# new-relic-deploy-tracking
simple new relic deploy tracking script, using graphql mutations

Usage:
```sh
deploy-tracking.sh "<pipeline link (or any other deeplink you want to use)>" $RELEASE_VERSION $NEWRELIC_API_KEY $COMMIT_SHA <"$COMMIT_MESSAGE"(or any link to a changelog)> "$PIPELINE_TRIGGERER_USERNAME" 
```
Getting started:
https://docs.newrelic.com/docs/apis/nerdgraph/get-started/introduction-new-relic-nerdgraph/


Documentation reference:
https://docs.newrelic.com/docs/apm/apm-ui-pages/events/record-deployments/

https://docs.newrelic.com/docs/change-tracking/change-tracking-graphql/

https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/

