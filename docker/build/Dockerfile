# vmangos-docker
# Copyright (C) 2021-present  Michael Serajnik  https://sr.ht/~mser/

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM ubuntu:20.04

ARG VMANGOS_USER_ID=1000
ARG VMANGOS_GROUP_ID=1000

ENV \
  VMANGOS_USER_ID=$VMANGOS_USER_ID \
  VMANGOS_GROUP_ID=$VMANGOS_GROUP_ID \
  DEBIAN_FRONTEND=noninteractive

RUN \
  apt-get update -y && \
  apt-get install -y \
    build-essential \
    ccache \
    cmake \
    git \
    libace-dev \
    libcurl4-openssl-dev \
    libmysqlclient-dev \
    libssl-dev \
    libtbb-dev \
    openssl \
    p7zip-full \
    zlib1g-dev

RUN \
  ln -s /usr/bin/ccache /usr/local/bin/gcc && \
  ln -s /usr/bin/ccache /usr/local/bin/g++ && \
  ln -s /usr/bin/ccache /usr/local/bin/cc && \
  ln -s /usr/bin/ccache /usr/local/bin/c++

RUN \
  export ACE_ROOT=/usr/include/ace && \
  export TBB_ROOT_DIR=/usr/include/tbb

COPY ./src/core/ /opt/core

RUN \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /opt/core && \
  mkdir -p /opt/vmangos && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /opt/vmangos && \
  mkdir -p /vmangos && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /vmangos && \
  mkdir -p /ccache && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /ccache && \
  mkdir -p /database && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /database && \
  mkdir -p /world_database && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /world_database

ENV \
  VMANGOS_THREADS=2 \
  VMANGOS_DEBUG=0 \
  VMANGOS_MALLOC=0 \
  VMANGOS_CLIENT=5875 \
  VMANGOS_EXTRACTORS=1 \
  VMANGOS_ANTICHEAT=0 \
  VMANGOS_SCRIPTS=1 \
  VMANGOS_LIBCURL=0 \
  VMANGOS_WORLD=world_full_14_june_2021

USER ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID}

CMD \
  mkdir /opt/core/build && \
  cd /opt/core/build && \
  cmake \
    -DDEBUG=$VMANGOS_DEBUG \
    -DUSE_STD_MALLOC=$VMANGOS_MALLOC \
    -DSUPPORTED_CLIENT_BUILD=$VMANGOS_CLIENT \
    -DUSE_EXTRACTORS=$VMANGOS_EXTRACTORS \
    -DUSE_ANTICHEAT=$VMANGOS_ANTICHEAT \
    -DSCRIPTS=$VMANGOS_SCRIPTS \
    -DUSE_LIBCURL=$VMANGOS_LIBCURL \
    -DCMAKE_INSTALL_PREFIX=/opt/vmangos ../ && \
  make -j $VMANGOS_THREADS && \
  make install && \
  mkdir /opt/vmangos/data && \
  mkdir /opt/vmangos/logs && \
  cp /opt/vmangos/etc/mangosd.conf.dist /opt/vmangos/etc/mangosd.conf && \
  cp /opt/vmangos/etc/realmd.conf.dist /opt/vmangos/etc/realmd.conf && \
  cp -r /opt/vmangos/* /vmangos && \
  cd /database && 7z e $VMANGOS_WORLD.7z && \
  rm -f /world_database/$VMANGOS_WORLD.sql && \
  mv $VMANGOS_WORLD.sql /world_database
