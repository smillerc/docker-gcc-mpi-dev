# A baseline docker image for mpi dev using openmpi

ARG FEDORA_VERSION

FROM fedora:${FEDORA_VERSION}

RUN dnf groupinstall "Development Tools" -y

RUN dnf install -y \
      openmpi-devel gfortran m4 \
      cmake wget zsh curl git \
      cgnslib-devel

# Install miniconda to /miniconda
RUN cd /tmp && \
      curl -LO http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
      bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b

ENV PATH=/miniconda/bin:${PATH}
RUN conda install -y numpy matplotlib scipy pandas && \
      conda clean --all

RUN pip install pre-commit fprettify

ENV PATH=/usr/lib64/openmpi/bin:${PATH}

# Add pFunit testing
RUN cd /tmp && git clone https://github.com/Goddard-Fortran-Ecosystem/pFUnit.git && \
      cd pFUnit && mkdir build && cd build && \
      FC=mpifort CC=gcc cmake .. -DCMAKE_INSTALL_PREFIX=/software && \
      make && make install ; exit 0

ENV PFUNIT_DIR /software/PFUNIT-4.0
ENV FARGPARSE_DIR /software/FARGPARSE-0.9
ENV GFTL_DIR /software/GFTL-1.1
ENV GFTL_SHARED_DIR /software/GFTL_SHARED-1.0

RUN rm -rf /tmp/*

# Add a default non-root user to run mpi jobs
ARG USER=mpi
ENV USER ${USER}
RUN adduser ${USER} \
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
RUN mkdir /tmp/mpi-tests
WORKDIR /tmp/mpi-tests
COPY mpi-test .
RUN sh test.sh
RUN rm -rf /tmp/mpi-test

# run the installation script  
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
# terminal colors with xterm
ENV TERM xterm
# set the zsh theme
ENV ZSH_THEME agnoster

WORKDIR ${USER_HOME}



CMD ["/bin/zsh"]
