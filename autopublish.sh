#!/bin/bash

QUIET="0"
for i in "$@"; do
  case $i in
    -q|--quiet)
    QUIET="1"
    ;;
  esac
done

if [ "$QUIET" -eq "0" ]; then
  set -x
fi

AUTOPUB_WORKING_DIR=/tmp/noVNC-autopublish
NOVNC_DIR=$AUTOPUB_WORKING_DIR/noVNC
NOVNC_REPO_GIT_URL=https://github.com/novnc/noVNC.git
NOVNC_CORE_DIR=$AUTOPUB_WORKING_DIR/noVNC-core
NOVNC_CORE_GIT_URL=git@github.com:larryprice/novnc-core.git

# Get latest repos
rm -rf $AUTOPUB_WORKING_DIR
mkdir $AUTOPUB_WORKING_DIR
git clone --depth=1 $NOVNC_REPO_GIT_URL $NOVNC_DIR
git clone $NOVNC_CORE_GIT_URL $NOVNC_CORE_DIR

# Generate new commonjs
cd $NOVNC_DIR
NOVNC_CURRENT_HASH=`git rev-parse HEAD`
npm install
./utils/use_require.js --as commonjs
cp -rf $NOVNC_DIR/lib/* $NOVNC_CORE_DIR/lib/
cp -rf $NOVNC_DIR/vendor/* $NOVNC_CORE_DIR/vendor/

# Determine differences
cd $NOVNC_CORE_DIR
NOVNC_CORE_VERSION=`git describe --tags $(git rev-list --tags --max-count=1)`
git diff --quiet
if [ "$?" -ne "0" ]; then
  # Sync
  echo "Found differences between noVNC noVNC/${NOVNC_CURRENT_HASH} and noVNC-core/${NOVNC_CORE_VERSION}"
  git add .
  git commit -m "Sync noVNC master (${NOVNC_CURRENT_HASH})"

  # Increment package version and update README
  NOVNC_CORE_NEXT_VERSION=`npm version patch`
  git reset HEAD~ # previous command makes a commit that we want to undo
  wc -l < README.md | tr -d '\n' >> /dev/null # trim any newlines from README.md
  echo "* ${NOVNC_CORE_NEXT_VERSION}" >> README.md
  echo "  * Maps to noVNC/noVNC ${NOVNC_CURRENT_HASH}" >> README.md
  git commit --amend -am "Sync noVNC/master (${NOVNC_CURRENT_HASH}) as novnc-core/${NOVNC_CORE_NEXT_VERSION}"
  git tag -d ${NOVNC_CORE_NEXT_VERSION}
  git tag ${NOVNC_CORE_NEXT_VERSION}

  # Publish
  git push origin master
  git push origin $NOVNC_CORE_NEXT_VERSION
  npm publish
fi

# cleanup
rm -rf $AUTOPUB_WORKING_DIR
