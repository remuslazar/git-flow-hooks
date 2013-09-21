#!/usr/bin/env bash

function __print_usage {
    echo "Usage: $(basename $0) [major|minor|patch|<semver>]"
    echo "    major|minor|patch: Version will be bumped accordingly."
    echo "    <semver>:          Version won't be bumped."
    exit 1
}

function __print_version {
    echo $VERSION_BUMPED
    exit 0
}

# parse arguments

if [ $# -gt 2 ]; then
    __print_usage
fi

VERSION_ARG="$(echo $1 | tr '[:lower:]' '[:upper:]')"

if [ -z $1 ] || [ $VERSION_ARG == "PATCH" ]; then
    VERSION_UPDATE_MODE="PATCH"
elif [ $VERSION_ARG == "MINOR" ]; then
    VERSION_UPDATE_MODE=$VERSION_ARG
elif [ $VERSION_ARG == "MAJOR" ]; then
    VERSION_UPDATE_MODE=$VERSION_ARG
elif [[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$ ]]; then
    # semantic version passed as argument
    VERSION_BUMPED=$VERSION_ARG
    __print_version
else
    __print_usage
fi

# read git tags

VERSION_PREFIX=$(git config --get gitflow.prefix.versiontag)
VERSION_TAG=$(git tag $VERSION_PREFIX* -l | tail -1)

if [ ! -z $VERSION_TAG ]; then
    if [ ! -z $VERSION_PREFIX ]; then
        VERSION_CURRENT=${VERSION_TAG#$VERSION_PREFIX}
    fi
fi

# read version file (if version not found by tags)

if [ -z $VERSION_CURRENT ]; then
    if [ -z $VERSION_FILE ]; then
        ROOT_DIR=$(git rev-parse --show-toplevel)
        VERSION_FILE="$ROOT_DIR/VERSION"
    fi

    if [ -f $VERSION_FILE ]; then
        VERSION_CURRENT=$(cat $VERSION_FILE)
    fi
fi

# use 0.0.0 (if version not found by file)

if [ -z $VERSION_CURRENT ]; then
    VERSION_CURRENT="0.0.0"
fi

# bump version

VERSION_LIST=($(echo $VERSION_CURRENT | tr '.' ' '))
VERSION_MAJOR=${VERSION_LIST[0]}
VERSION_MINOR=${VERSION_LIST[1]}
VERSION_PATCH=${VERSION_LIST[2]}

if [ $VERSION_UPDATE_MODE == "PATCH" ]; then
    VERSION_PATCH=$((VERSION_PATCH + 1))
elif [ $VERSION_UPDATE_MODE == "MINOR" ]; then
    VERSION_MINOR=$((VERSION_MINOR + 1))
    VERSION_PATCH=0
else
    VERSION_MAJOR=$((VERSION_MAJOR + 1))
    VERSION_MINOR=0
    VERSION_PATCH=0
fi

VERSION_BUMPED="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH"

__print_version