#!/bin/bash

alias docker=podman

tag=$1
topic=$2

echo $tag
echo $topic

sleep 3

#docker build --tag $tag -f ./Dockerfile
docker build -t $tag .
#docker run -it --env QUERY_TERM=$topic --name ControversyDetector $tag
docker run -it --env QUERY_TERM="${topic}" $tag
