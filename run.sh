#!/bin/bash
NAME=
IMAGE=
TAG=
ARGS=
MOUNT_SOURCE=
MOUNT_TARGET=
PORT_SOURCE=
PORT_TARGET=

docker pull $IMAGE:$TAG
docker stop $NAME
docker rm $NAME
docker run -d --restart=always --name=$NAME -p $PORT_SOURCE:$PORT_TARGET -v $MOUNT_SOURCE:$MOUNT_TARGET $IMAGE:$TAG $ARGS
