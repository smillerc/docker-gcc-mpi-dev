#!/bin/bash

tag=8.3
docker build --build-arg GCC_VERSION=${tag} -t smillerc/gcc-mpi-dev:${tag} -f Dockerfile .
docker push smillerc/gcc-mpi-dev:${tag}
