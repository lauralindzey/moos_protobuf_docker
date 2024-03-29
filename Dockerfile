FROM moosivp/moos-ivp:r9526

USER root
# All RUN commands start in this directory; state is not maintained between.
WORKDIR /home/moos
ENV MOOS_DIR=/home/moos/moos-ivp/build/MOOS/MOOSCore

# Builts were failing with "Unable to fetch some archives, maybe run apt-get update or try with --fix-missing"
RUN apt update
RUN apt install -y git

# google test
RUN git clone https://github.com/google/googletest.git -b release-1.10.0
RUN cd googletest && mkdir build && cd build && cmake .. -DBUILD_GMOCK=OFF && make && make install

# g3log
RUN git clone https://github.com/KjellKod/g3log.git
RUN cd g3log && mkdir build && cd build && cmake .. && make && make install

# Pyproj. From source for now because 18.04 doesn't have the right version in the debs.
RUN apt install -y cmake make g++ libtiff-dev sqlite3 libsqlite3-dev libcurl4-gnutls-dev
RUN git clone https://github.com/OSGeo/PROJ.git
RUN cd PROJ && mkdir build && cd build && cmake .. && make && make install

# We also use the tf2 library
RUN apt install -y libeigen3-dev 
RUN apt install -y libtf2-dev 
RUN apt install -y libtf2-eigen-dev

# Install pymoos
RUN apt install -y python3
RUN apt install -y python3-setuptools
RUN apt install -y python3-dev  
RUN git clone https://github.com/msis/python-moos.git
RUN cd python-moos && python3 setup.py build && python3 setup.py install

# Protobuf dependencies; do protobuf last because it's so slow.
RUN apt install -y autoconf automake libtool curl make g++ unzip
RUN git clone https://github.com/protocolbuffers/protobuf.git
RUN cd protobuf && git submodule update --init --recursive && ./autogen.sh
# For some reason, make check fails when building on hub.docker.com, but not locally.
#RUN cd protobuf && ./configure && make && make check && make install && ldconfig
RUN cd protobuf && ./configure && make && make install && ldconfig
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib

# Our test repo
RUN apt install -y libboost-all-dev
RUN git clone https://github.com/lindzey/moos_experiments.git
RUN cd moos_experiments && mkdir build && cd build && cmake .. && make && make install
ENV PATH=${PATH}:/home/moos/moos_experiments/devel/bin
