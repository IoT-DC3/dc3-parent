#!/bin/bash

#
# Copyright 2016-present the IoT DC3 original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

WAIT_TIME=10

echo "wait 10s"
sleep "$WAIT_TIME"

STAGING_REPO_ID=$(curl -u $SERVER_USERNAME:$SERVER_PASSWORD \
                -X GET \
                "$SERVER_URL/service/local/staging/profile_repositories" \
                -H "Accept:application/json" \
                | jq -r ".data | map(select(.type == \"open\")) | sort_by(.updatedTimestamp) | .[-1].repositoryId")
echo "last staging repository: $STAGING_REPO_ID"

if [ -n "$STAGING_REPO_ID" ]; then
    echo "close staging repository: $STAGING_REPO_ID"
    curl -u $SERVER_USERNAME:$SERVER_PASSWORD \
                -X POST \
                "$SERVER_URL/service/local/staging/bulk/close" \
                -H "Content-Type:application/json" \
                -H "Accept:application/json,application/vnd.siesta-error-v1+json,application/vnd.siesta-validation-errors-v1+json" \
                -d "{\"data\":{\"description\":\"github action close\",\"stagedRepositoryIds\":[\"$STAGING_REPO_ID\"]}}"

    while true; do
        STAGING_REPO_TYPE=$(curl -u $SERVER_USERNAME:$SERVER_PASSWORD \
                          -X GET \
                          "$SERVER_URL/service/local/staging/profile_repositories" \
                          -H "Accept:application/json" \
                          | jq -r ".data | map(select(.repositoryId == \"$STAGING_REPO_ID\")) | .[0].type")
        echo "staging repository: $STAGING_REPO_ID, status: $STAGING_REPO_TYPE"
        if [ "$STAGING_REPO_TYPE" == "closed" ]; then
            break
        fi

    echo "wait 10s"
    sleep "$WAIT_TIME"
    done

    echo "release staging repository: $STAGING_REPO_ID"
    curl -u $SERVER_USERNAME:$SERVER_PASSWORD \
                -X POST \
                "$SERVER_URL/service/local/staging/bulk/promote" \
                -H "Content-Type:application/json" \
                -d "{\"data\":{\"description\":\"github action release\",\"autoDropAfterRelease\":true,\"stagedRepositoryIds\":[\"$STAGING_REPO_ID\"]}}"
fi
