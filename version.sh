#!/bin/bash
DESC=($(git describe --match 'v*' | sed "s/v\([0-9\.]*\)-*\([0-9]*\)-*\([0-9a-z]*\)/\1 \2 \3/"))
VERSION=($(echo ${DESC[0]} | tr "." " "))
COMMIT=${DESC[1]}
VERSION_MAJ=${VERSION[0]}
VERSION_MIN=${VERSION[1]}
VERSION_REV=${COMMIT}
if [ -z "${VERSION_REV}" ]; then
    VERSION_REV="0"
fi

#Allow local revision identifiers
#mimicing backports this is "-<identifier>"
if [ -e localversion ]; then
    LOCAL_REV=$(cat localversion)
    if [ -n "${LOCAL_REV}" ];
    then
        LOCAL_REV="-${LOCAL_REV}"
    fi
fi

while getopts "mnr" opt; do
    case $opt in
        m)
            # Major Version 
            echo "${VERSION_MAJ}"
            exit 0
            ;;
        n)
            # Minor Version
            echo "${VERSION_MIN}"
            exit 0
            ;;
        r)
            # Revision Version 
            echo "${VERSION_REV}"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

VERSION="${VERSION_MAJ}.${VERSION_MIN}.${VERSION_REV}${LOCAL_REV}"

if [ -e src/diamond/version.py.tmpl ]
then
    cat src/diamond/version.py.tmpl | sed "s/__VERSIONTOKENHERE__/${VERSION}/g" > src/diamond/version.py
fi

echo $VERSION
