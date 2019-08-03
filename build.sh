#!/bin/bash

tag=9.1
docker build -t smillerc/gcc-mpi-dev:${tag} -f Dockerfile .
docker push smillerc/gcc-mpi-dev:${tag}
