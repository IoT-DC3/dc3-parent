#!/bin/bash

WAIT_TIME=10
sleep "${WAIT_TIME}"
STAGING_REPO_ID=$(curl -u "${SERVER_USERNAME}:${SERVER_PASSWORD}" \
                -X GET \
                "${SERVER_URL}/service/local/staging/profile_repositories" \
                -H "Accept:application/json" \
                | jq -r '.data | map(select(.type == "open")) | sort_by(.updatedTimestamp) | .[-1].repositoryId')
if [ -n "${STAGING_REPO_ID}" ]; then
    curl -v -u ${SERVER_USERNAME}:${SERVER_PASSWORD} \
                -X POST \
                "${SERVER_URL}/service/local/staging/bulk/close" \
                -H "Content-Type:application/json" \
                -d '{"data":{"description":"github action close","stagedRepositoryIds":["${STAGING_REPO_ID}"]}}'
    while true; do
        STAGING_REPO_TYPE=$(curl -u "${SERVER_USERNAME}:${SERVER_PASSWORD}" \
                          -X GET \
                          "${SERVER_URL}/service/local/staging/profile_repositories" \
                          -H "Accept:application/json" \
                          | jq -r '.data | map(select(.repositoryId == "${STAGING_REPO_ID}")) | .[0].type')
        if [ "${STAGING_REPO_TYPE}" == "closed" ]; then
            break
        fi
    sleep "${WAIT_TIME}"
    done
    curl -v -u ${SERVER_USERNAME}:${SERVER_PASSWORD} \
                -X POST \
                "https://s01.oss.sonatype.org/service/local/staging/bulk/promote" \
                -H "Content-Type:application/json" \
                -d '{"data":{"description":"github action release","autoDropAfterRelease":true,"stagedRepositoryIds":["${STAGING_REPO_ID}"]}}'
fi
