#!/bin/bash

tag=9.1
docker build --build-arg FEDORA_VERSION="latest" -t smillerc/gcc-mpi-dev:${tag} -f Dockerfile .
docker push smillerc/gcc-mpi-dev:${tag}
