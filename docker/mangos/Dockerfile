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
    libace-dev \
    libcurl4-openssl-dev \
    libmysqlclient-dev \
    libssl-dev \
    libtbb-dev \
    openssl \
    zlib1g-dev

RUN \
  mkdir -p /opt/vmangos && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /opt/vmangos

COPY ./vmangos/bin/mangosd /opt/vmangos/bin/mangosd
RUN chmod +x /opt/vmangos/bin

ADD \
  https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait \
  /opt/wait
RUN chmod +x /opt/wait

WORKDIR /opt/vmangos/bin

USER ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID}

CMD /opt/wait && ./mangosd -c /opt/vmangos/etc/mangosd.conf
