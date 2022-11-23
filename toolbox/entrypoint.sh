#!/bin/env sh
USER=${USER:-dev}

groupmod -g `stat -c %g /var/run/docker.sock` docker

exec gosu ${USER} "$@"
exit 0
