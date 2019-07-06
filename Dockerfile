# A baseline docker image for mpi dev using openmpi

FROM gcc:9.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
                      cmake libhdf5-dev libcgns-dev build-essential \
                      zsh git libopenmpi-dev

# Add a default non-root user to run mpi jobs
ARG USER=mpi
ENV USER ${USER}
RUN adduser --disabled-password ${USER} \
      && echo "${USER}   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV USER_HOME /home/${USER}
RUN chown -R ${USER}:${USER} ${USER_HOME}

# Create working directory
ARG WORKDIR=/project
ENV WORKDIR ${WORKDIR}
RUN mkdir ${WORKDIR}
RUN chown -R ${USER}:${USER} ${WORKDIR}

WORKDIR ${WORKDIR}
USER ${USER}

# Test mpi
RUN mkdir /tmp/mpi-test
WORKDIR /tmp/mpi-test
COPY mpi-test .
RUN sh test.sh
RUN rm -rf /tmp/mpi-test

# CLEAN UP
WORKDIR /
RUN rm -rf /tmp/*

CMD ["/bin/zsh"]
