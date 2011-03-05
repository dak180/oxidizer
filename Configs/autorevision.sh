#!/bin/bash

# autorevision.sh - a hacked up shellscript to get git revisions etc. into binary builds.
# Defines are named as they are for historical reasons.
# To use pass a path to the desired output file: some/path/to/autorevision.h.

TARGETFILE="${1}"

cd "${SRCROOT}"

# Is the working copy clean?
git diff --quiet HEAD &> /dev/null
WC_MODIFIED="${?}"

# Enumeration of changesets
GIT_NUM="$(git rev-list --count HEAD)"

# The full revision hash
GIT_FULL_HASH="$(git rev-parse HEAD)"

# The short hash
GIT_SHORT_HASH="$(echo ${GIT_FULL_HASH} | cut -b 1-7)"

# Current branch
GIT_URI="$(git symbolic-ref HEAD)"

# Current tag (or branch if there is no tag)
GIT_TAG="$(git describe --exact-match --tags 2>/dev/null)"
if [ -z "${GIT_TAG}" ]; then
	GIT_TAG="${GIT_URI}"
fi

# Date of the last commit
GIT_DATE="$(git log -1 --pretty=format:%ci)"

cat > "${TARGETFILE}" << EOF
/* ${GIT_FULL_HASH} */
#ifndef AUTOREVISION_H
#define AUTOREVISION_H

#define GIT_NUM			${GIT_NUM}
#define GIT_DATE		${GIT_DATE}
#define GIT_URI			${GIT_URI}
#define GIT_TAG			${GIT_TAG}

#define GIT_FULL_HASH					${GIT_FULL_HASH}
#define GIT_SHORT_HASH					${GIT_SHORT_HASH}

#define GIT_WC_MODIFIED					${WC_MODIFIED}

#endif

EOF
