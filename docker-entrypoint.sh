#!/bin/bash

set -e

sed 's#CARBONLINK_HOSTS = .*#CARBONLINK_HOSTS = ["'"$CARBON_HOST]"':7002"]#' -i /opt/graphite/webapp/graphite/local_settings.py;

# Add gunicorn as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- gunicorn "$@"
fi

# No need to do gosu (gunicorn takes care of stepping down from root)  
if [ "$1" = 'gunicorn' ]; then
		chown -R graphiteweb:graphiteweb /opt/graphite
fi

# As argument is not related to gunicorn,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"