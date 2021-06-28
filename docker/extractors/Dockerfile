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
ARG DEBIAN_FRONTEND=noninteractive

ENV \
  VMANGOS_USER_ID=$VMANGOS_USER_ID \
  VMANGOS_GROUP_ID=$VMANGOS_GROUP_ID

RUN \
  apt-get update -y && \
  apt-get install -y \
    libace-dev \
    libcurl4-openssl-dev \
    libmysqlclient-dev \
    libssl-dev \
    libtbb-dev \
    openssl \
    zlib1g-dev

RUN \
  mkdir -p /opt/vmangos && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /opt/vmangos && \
  mkdir -p /client_data && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /client_data && \
  mkdir -p /mmap_contrib && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /mmap_contrib

COPY ./vmangos/bin/mapextractor /opt/vmangos/bin/mapextractor
COPY ./vmangos/bin/vmapextractor /opt/vmangos/bin/vmapextractor
COPY ./vmangos/bin/vmap_assembler /opt/vmangos/bin/vmap_assembler
COPY ./vmangos/bin/MoveMapGen /opt/vmangos/bin/MoveMapGen
RUN chmod +x /opt/vmangos/bin

WORKDIR /client_data

USER ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID}

CMD /opt/vmangos/bin/mapextractor /client_data