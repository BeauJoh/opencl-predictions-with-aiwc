# An Ubuntu environment configured for building the phd repo.
#FROM nvidia/opencl
FROM ubuntu:18.04

MAINTAINER Beau Johnston <beau.johnston@anu.edu.au>

# Disable post-install interactive configuration.
# For example, the package tzdata runs a post-installation prompt to select the
# timezone.
ENV DEBIAN_FRONTEND noninteractive

# Setup the environment.
ENV HOME /root
ENV USER docker
ENV LSB_SRC /libscibench-source
ENV LSB /libscibench
ENV LEVELDB_SRC /leveldb-source
ENV LEVELDB_ROOT /leveldb
ENV OCLGRIND_SRC /oclgrind-source
ENV OCLGRIND /oclgrind
ENV OCLGRIND_BIN /oclgrind/bin/oclgrind
ENV GIT_LSF /git-lsf
ENV PREDICTIONS /opencl-predictions-with-aiwc
ENV EOD /OpenDwarfs

# Install essential packages.
RUN apt-get update
RUN apt-get install --no-install-recommends -y software-properties-common \
    ocl-icd-opencl-dev \
    pkg-config \
    build-essential \
    git \
    make \
    zlib1g-dev \
    apt-transport-https \
    wget

# Install cmake -- newer version than with apt
RUN wget -qO- "https://cmake.org/files/v3.12/cmake-3.12.1-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr

# Install OpenCL Device Query tool
RUN git clone https://github.com/BeauJoh/opencl_device_query.git /opencl_device_query

# Install LibSciBench
RUN apt-get install --no-install-recommends -y llvm-3.9 llvm-3.9-dev clang-3.9 libclang-3.9-dev gcc g++
RUN git clone https://github.com/spcl/liblsb.git $LSB_SRC
WORKDIR $LSB_SRC
RUN ./configure --prefix=$LSB
RUN make
RUN make install

# Install leveldb (optional dependency for OclGrind)
RUN git clone https://github.com/google/leveldb.git $LEVELDB_SRC
RUN mkdir $LEVELDB_SRC/build
WORKDIR $LEVELDB_SRC/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=$LEVELDB_ROOT
RUN make
RUN make install

# Install OclGrind
RUN git clone https://github.com/BeauJoh/Oclgrind.git $OCLGRIND_SRC

RUN mkdir $OCLGRIND_SRC/build
WORKDIR $OCLGRIND_SRC/build
ENV CC clang-3.9
ENV CXX clang++-3.9

RUN cmake $OCLGRIND_SRC -DUSE_LEVELDB=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_DIR=/usr/lib/llvm3.9/lib/cmake -DCLANG_ROOT=/usr/lib/clang/3.9.1 -DCMAKE_INSTALL_PREFIX=$OCLGRIND

RUN make
RUN make install

# Install R and model dependencies
RUN apt-get install --no-install-recommends -y dirmngr gpg-agent
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
#RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
#RUN add-apt-repository ppa:marutter/rdev
#RUN apt-get update
#RUN apt-get -y upgrade
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN apt-get -y --no-install-recommends update
RUN apt-get -y --no-install-recommends install r-base-dev r-base-core r-recommended
RUN apt-get install -t bionic -y libcurl4-openssl-dev 
RUN apt-get install -t bionic -y libssl-dev
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "devtools::install_github('imbs-hl/ranger')"

# Install the git-lsf module
#WORKDIR /downloads
#RUN wget https://github.com/git-lfs/git-lfs/releases/download/v2.5.1/git-lfs-linux-amd64-v2.5.1.tar.gz
#RUN mkdir $GIT_LSF
#RUN tar -xvf git-lfs-linux-amd64-v2.5.1.tar.gz --directory $GIT_LSF
#WORKDIR $GIT_LSF
#RUN ./install.sh
#RUN git lfs install
#
## Install the R model
#RUN git clone https://github.com/BeauJoh/opencl-predictions-with-aiwc.git $PREDICTIONS

# Install beakerx
RUN apt-get install --no-install-recommends -y python3-pip python3-setuptools python3-dev libreadline-dev libpcre3-dev libbz2-dev liblzma-dev libicu-dev
RUN pip3 install --upgrade pip
RUN pip3 install --ignore-installed pyzmq
RUN pip3 install tzlocal rpy2 requests ipywidgets beakerx pandas py4j

# Install R module for beakerx
RUN Rscript -e "devtools::install_github('IRkernel/IRkernel')"\
    && Rscript -e "IRkernel::installspec(user = FALSE)"\
    && Rscript -e "devtools::install_github('cran/RJSONIO')"\
    && Rscript -e "devtools::install_github('r-lib/httr')"\
    && Rscript -e "devtools::install_github('tidyverse/magrittr')"\
    && Rscript -e "devtools::install_github('tidyverse/ggplot2')"\
    && Rscript -e "devtools::install_github('tidyverse/tidyr')"\
    && Rscript -e "devtools::install_github('BeauJoh/fmsb')"\
    && Rscript -e "devtools::install_github('wilkelab/cowplot')"\
    && Rscript -e "devtools::install_github('cran/gridGraphics')"\
    && Rscript -e "devtools::install_github('cran/Metrics')"\
    && Rscript -e "devtools::install_github('cran/latex2exp')"\
    && Rscript -e "devtools::install_github('cran/akima')" \
    && Rscript -e "devtools::install_github('cran/pander')"
RUN beakerx install

# Install LetMeKnow
RUN pip3 install -U 'lmk==0.0.14'
# setup lmk by copying or add .lmkrc to /root/
# is used as: python3 ../opendwarf_grinder.py 2>&1 | lmk -
# or: lmk 'python3 ../opendwarf_grinder.py'

# Install EOD
RUN apt-get install --no-install-recommends -y automake autoconf libtool
RUN git clone https://github.com/BeauJoh/OpenDwarfs.git $EOD
WORKDIR $EOD
RUN ./autogen.sh
RUN mkdir build
WORKDIR $EOD/build
RUN ../configure --with-libscibench=$LSB
RUN make

# Install git-lfs
WORKDIR /git-lfs
RUN wget https://github.com/git-lfs/git-lfs/releases/download/v2.5.1/git-lfs-linux-amd64-v2.5.1.tar.gz
RUN tar -xvf git-lfs-linux-amd64-v2.5.1.tar.gz
RUN ./install.sh
RUN git lfs install

CMD ["/bin/bash"]

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

##change ownership of all projects needed for investigation
##RUN chown -R ${NB_UID} ${EOD}
##RUN chown -R ${NB_UID} ${PREDICTIONS}
#RUN chown -R ${NB_UID} ${LSB}
#RUN chown -R ${NB_UID} ${LEVELDB_ROOT}
#RUN chown -R ${NB_UID} ${OCLGRIND}
#
#COPY . /workspace
WORKDIR /workspace
#ENV LD_LIBRARY_PATH "${OCLGRIND}/lib:${LSB}/lib:${LD_LIBRARYPATH}"
#ENV PATH "${PATH}:${OCLGRIND}/bin}"
#
##start beakerx/jupyter by default
##CMD ["beakerx", "--allow-root"]
#CMD ["/bin/bash"]
