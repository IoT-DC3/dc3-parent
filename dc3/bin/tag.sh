#!/bin/bash

#
# Copyright 2016-present the IoT DC3 original author or authors.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

set -euo pipefail

branch="$(git rev-parse --abbrev-ref HEAD)"
type=""

if [[ "${branch}" == "develop" ]]; then
    type="develop"
elif [[ "${branch}" == "release" || "${branch}" == "main" ]]; then
    type="release"
fi

if [[ -z "${type}" ]]; then
    echo -e "This branch doesn't support tagging, please switch to the \033[31mdevelop\033[0m, \033[31mrelease\033[0m, or \033[31mmain\033[0m branch."
    exit 1
fi

# Sync remote tags before allocating the next sequence number.
git fetch --tags --prune

date_part="$(date +'%Y%m%d')"
prefix="dc3.${type}.${date_part}"
tag=""

for i in $(seq 0 99); do
    candidate="${prefix}.${i}"
    if ! git rev-parse -q --verify "refs/tags/${candidate}" >/dev/null; then
        tag="${candidate}"
        break
    fi
done

if [[ -z "${tag}" ]]; then
    echo "No available tag index for ${prefix}.0-99. Please clean old tags or adjust naming strategy."
    exit 1
fi

echo "${tag}"
git tag "${tag}"
git push origin "${tag}"
