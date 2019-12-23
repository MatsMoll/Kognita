if [[ "true" == "${DEBUG}" ]]; then
    set -x
fi

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "error: not found GITHUB_TOKEN"
    exit 1
fi

# These are provided by actions
if [ -z "${GITHUB_REPOSITORY}" ]; then
    echo "error: not found GITHUB_REPOSITORY"
    exit 1
fi

# These are provided by actions
if [ -z "${GITHUB_SHA}" ]; then
    echo "error: not found GITHUB_SHA"
    exit 1
fi

function fetch_related_files {
    QUERY="q=repo:${GITHUB_REPOSITORY}%20type:pr%20is:closed%20is:merged%20SHA:${GITHUB_SHA}"
    curl --silent --header "Authorization: token ${GITHUB_TOKEN}" \
         --url "https://api.github.com/search/issues?${QUERY}" \
         > related_prs

    curl --silent --header "Authorization: token ${GITHUB_TOKEN}" \
         --url "https://api.github.com/repos/${GITHUB_REPOSITORY}/commits/${GITHUB_SHA}" \
         > last_commit

    curl --silent --header "Authorization: token ${GITHUB_TOKEN}" \
         --url "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/latest" \
         > last_release
}

function pr_has_label {
    jq --arg labelname "$1" '.items[0].labels | map_values(.name) | contains([$labelname])' -r related_prs
}

function generate_new_release_data {

    LAST_TAG_NAME=$(jq ".tag_name" last_release -r || echo "0.0.0")
    LAST_VERSION=${LAST_TAG_NAME%%"-"*}

    #replace . with space so can split into an array
    VERSION_BITS=(${LAST_VERSION//./ })

    #get number parts and increase last one by 1
    MAJOR_VERSION=${VERSION_BITS[0]:-1}
    MINOR_VERSION=${VERSION_BITS[1]:-0}
    BUILD_VERSION=${VERSION_BITS[2]:-(-1)}

    if [[ "true" == $(pr_has_label "release:major") ]]; then
        MAJOR_VERSION=$((MAJOR_VERSION+1))
        MINOR_VERSION=0
        BUILD_VERSION=0
    elif [[ "true" == $(pr_has_label "release:minor") ]]; then
        MINOR_VERSION=$((MINOR_VERSION+1))
        BUILD_VERSION=0
    else
        BUILD_VERSION=$((BUILD_VERSION+1))
    fi

    #create new tag
    NEXT_VERSION="$MAJOR_VERSION.$MINOR_VERSION.$BUILD_VERSION"

    git tag $NEXT_VERSION
    CHANGE_LOG="$(finch compare --release-manager="mem@mollestad.no" --project-dir="." --config="./CI/finch-config.yml" --no-fetch)"

    cat << EOF > new_release_data
{
  "tag_name": "${NEXT_VERSION}",
  "target_commitish": "${GITHUB_SHA}",
  "name": "${NEXT_VERSION}",
  "body": "${CHANGE_LOG}",
  "draft": false,
  "prerelease": false
}
EOF

    echo "Next version set to be: ${NEXT_VERSION}"
}


function skip_if_norelease_set {
    COMMIT_TITLE=$(jq '.commit.message' last_commit -r | head -n 1)

    if [[ $COMMIT_TITLE == *'[norelease]'* ]]; then
        echo 'Skipping release. Reason: git commit title contains [norelease]'
        exit
    fi

    PR_URL=$(jq '.items[0].url' -r related_prs)
    if [[ "true" == $(pr_has_label "norelease") ]]; then
        echo "Skipping release. Reason: related PR has label norelease. PR: ${PR_URL}"
        exit
    fi
}


function create_new_release {
    if [ -z "$DRYRUN" ]; then
        curl --silent --header "Authorization: token ${GITHUB_TOKEN}" \
             --url "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" \
             --request POST \
             --data @new_release_data
    else
        echo "DRYRUN set, would have created a new release with the contents:"
        cat new_release_data
    fi
}

fetch_related_files
generate_new_release_data
skip_if_norelease_set
create_new_release
