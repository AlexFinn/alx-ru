#!/bin/bash

set -e

usage () {
    cat<<EOF
${0#*/}: Generate, and launch locally or deploy static websitee

Usage: ${0#*/} -e [COMMAND]
Arguments:
  -e       -   Launch command (deploy or local)
EOF
    exit 1
}

while getopts "e:h" option; do
    case $option in
        e)  COMMAND=${OPTARG} ;;
        h)  usage ;;
        *)  usage ;;
    esac
done

if [[ "${COMMAND}" != 'deploy'  &&  "${COMMAND}" != 'local' ]] ; then
    usage
fi

if [[ "${COMMAND}" == 'deploy' ]] ; then
    hugo -t '../../slim-alx-extended' && rsync -avz --delete public/ scale:/srv/www/alxf/alx-ru
fi

if [[ "${COMMAND}" == 'local' ]] ; then
    hugo server -t '../../slim-alx-extended' --buildDrafts --watch --disableFastRender
fi
