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

update_project_version() {
    local target_version="$1"
    local pom_file="pom.xml"
    local tmp_file=""
    local seen_artifact=0
    local replaced=0

    tmp_file="$(mktemp)"
    while IFS= read -r line; do
        if [[ ${seen_artifact} -eq 0 && "${line}" == *"<artifactId>dc3-parent</artifactId>"* ]]; then
            seen_artifact=1
        fi

        if [[ ${seen_artifact} -eq 1 && ${replaced} -eq 0 && "${line}" == *"<version>"*"</version>"* ]]; then
            local indent
            indent="${line%%<version>*}"
            echo "${indent}<version>${target_version}</version>" >> "${tmp_file}"
            replaced=1
        else
            echo "${line}" >> "${tmp_file}"
        fi
    done < "${pom_file}"

    if [[ ${replaced} -eq 0 ]]; then
        rm -f "${tmp_file}"
        echo "Failed to update ${pom_file}: project version node not found."
        exit 1
    fi

    mv "${tmp_file}" "${pom_file}"
}

repo_root="$(git rev-parse --show-toplevel)"
cd "${repo_root}"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Working tree is not clean. Please commit or stash local changes first."
    exit 1
fi

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

git fetch --tags --prune origin
git pull --rebase origin "${branch}"

year="$(date +'%Y')"
month=$((10#$(date +'%m')))
day=$((10#$(date +'%d')))
date_part="${year}$(printf '%02d%02d' "${month}" "${day}")"
base_version="${year}.${month}.${day}"
prefix="dc3.${type}.${date_part}"
tag=""
index=""

for i in $(seq 0 99); do
    candidate="${prefix}.${i}"
    if ! git rev-parse -q --verify "refs/tags/${candidate}" >/dev/null; then
        tag="${candidate}"
        index="${i}"
        break
    fi
done

if [[ -z "${tag}" || -z "${index}" ]]; then
    echo "No available tag index for ${prefix}.0-99. Please clean old tags or adjust naming strategy."
    exit 1
fi

new_version="${base_version}"
if [[ "${index}" -gt 0 ]]; then
    new_version="${base_version}.${index}"
fi

update_project_version "${new_version}"

git add pom.xml
git commit -m "release: ${new_version}"

echo "Version: ${new_version}"
echo "Tag: ${tag}"

git tag "${tag}"
git push origin "${branch}" "${tag}"
