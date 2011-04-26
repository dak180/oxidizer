#!/bin/bash

# Config
DirectorY="$1"
OutDir="$2"
FileName="$3"
SourceDLP="$4"
MD5Sum="$5"


# Make sure we are in the right place
cd "${SRCROOT}"
if [ ! -d "external" ]; then
    mkdir external
fi
cd external

# Checks
if [ "${ACTION}" = "clean" ]; then
    # Force cleaning when directed
    rm -fRv "${DirectorY}" "${OutDir}"
    MD5SumLoc=`md5 -q "${FileName}"`
    if [ "${MD5SumLoc}" != "${MD5Sum}" ]; then
        rm -fRv "${FileName}"
    fi
    exit 0
elif [ -d "${DirectorY}" ]; then
    # Clean if dirty
    echo "error: ${DirectorY} exists, probably from an earlier failed run" >&2
    #rm -fRv "${DirectorY}"
    exit 1
elif [[ -d "${OutDir}" ]] && [[ ! -f "${FileName}" ]]; then
    # Clean up when updating versions
    echo "error: Cached file is outdated or incomplete, removing" >&2
    rm -fR "${DirectorY}" "${OutDir}" "${BUILT_PRODUCTS_DIR}/${FULL_PRODUCT_NAME}" "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}" "${TARGET_TEMP_DIR}"
elif [[ -d "${OutDir}" ]] && [[ -f "${FileName}" ]]; then
    # Check to make sure we have the right file
    MD5SumLoc=`md5 -q "${FileName}"`
    if [ "${MD5SumLoc}" != "${MD5Sum}" ]; then
        echo "error: Cached file is outdated or incorrect, removing" >&2
        rm -fR "${FileName}" "${DirectorY}" "${OutDir}" "${BUILT_PRODUCTS_DIR}/${FULL_PRODUCT_NAME}" "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}" "${TARGET_TEMP_DIR}"
    else
        # Do not do more work then we have to
        echo "${OutDir} already exists, skipping"
        exit 0
    fi
fi

# Fetch
if [ ! -r "${FileName}" ]; then
    echo "Fetching ${SourceDLP}"
    if ! curl -Lfo "${FileName}" --connect-timeout "30" "${SourceDLP}"; then
        echo "error: Unable to fetch ${SourceDLP}" >&2
        exit 1
    fi
else
    echo "${FileName} already exists, skipping"
fi

# Check our sums
MD5SumLoc=`md5 -q "${FileName}"`
if [ -z "${MD5SumLoc}" ]; then
    echo "error: Unable to compute md5 for ${FileName}" >&2
    exit 1
elif [ "${MD5SumLoc}" != "${MD5Sum}" ]; then
    echo "error: MD5 does not match for ${FileName}" >&2
    exit 1
fi

# Unpack
ExtensioN=`echo ${FileName} | sed -e 's:^.*\.\([^.]*\):\1:'`
if [ "${ExtensioN}" = "gz" ]; then
    if ! tar -zxf "${FileName}"; then
        echo "error: Unpacking ${FileName} failed" >&2
        exit 1
    fi
elif [ "${ExtensioN}" = "bz2" ]; then
    if ! tar -jxf "${FileName}"; then
        echo "error: Unpacking ${FileName} failed" >&2
        exit 1
    fi
else
    echo "error: Unable to unpack ${FileName}" >&2
    exit 1
fi

# Move
if [ ! -d "${DirectorY}" ]; then
    echo "error: Can't find ${DirectorY} to rename" >&2
    exit 1
else
    mv "${DirectorY}" "${OutDir}"
    touch ${OutDir}/*
fi

exit 0
