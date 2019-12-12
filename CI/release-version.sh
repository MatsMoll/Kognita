#!/usr/bin/env bash

#get highest tag number
BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
VERSION=`git tag -l --sort -version:refname | head -n 1` # newest version
GIT_COMMIT=`git rev-parse HEAD`

if [[ $BRANCH_NAME == *"-rc" ]]; then
VERSION=`git describe --abbrev=0` # latest tag on branch
VERSION=${VERSION%%"-"*}
RC_TAG="$VERSION-$GIT_COMMIT-$BRANCH_NAME"
echo "Tagged with $RC_TAG"
git tag $RC_TAG
git push origin $RC_TAG
exit 0
fi

#removes rc tag if added
VERSION=${VERSION%%"-"*}

#replace . with space so can split into an array
VERSION_BITS=(${VERSION//./ })

#get number parts and increase last one by 1
MAJOR_VERSION=${VERSION_BITS[0]:-1}
MINOR_VERSION=${VERSION_BITS[1]:-0}
BUILD_VERSION=${VERSION_BITS[2]:-(-1)}

#get current hash and see if it already has a tag
GIT_MESSAGE="$(git log --format=%B -n 1 $GIT_COMMIT)"
NEEDS_TAG=`git describe --contains $GIT_COMMIT`

# Bumping version
if [[ $GIT_MESSAGE == *"-MAJOR-"* ]]; then
MAJOR_VERSION=$((MAJOR_VERSION+1))
MINOR_VERSION=0
BUILD_VERSION=0
elif [[ $GIT_MESSAGE == *"-MINOR-"* ]]; then
MINOR_VERSION=$((MINOR_VERSION+1))
BUILD_VERSION=0
else
BUILD_VERSION=$((BUILD_VERSION+1))
fi

#create new tag
NEW_TAG="$MAJOR_VERSION.$MINOR_VERSION.$BUILD_VERSION"

echo "Updating $VERSION to $NEW_TAG"
echo "Tagged with $NEW_TAG (Ignoring fatal:cannot describe - this means commit is untagged) "

git tag $NEW_TAG
git push origin $NEW_TAG
