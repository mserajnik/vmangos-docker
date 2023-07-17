# vmangos-docker
# Copyright (C) 2021-present  Michael Serajnik  https://github.com/mserajnik

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

FROM mariadb:10

ARG VMANGOS_USER_ID=1000
ARG VMANGOS_GROUP_ID=1000

ENV \
  VMANGOS_USER_ID=$VMANGOS_USER_ID \
  VMANGOS_GROUP_ID=$VMANGOS_GROUP_ID \
  VMANGOS_WORLD=world_full_14_june_2021

RUN \
  mkdir -p /backup && \
  chown -R ${VMANGOS_USER_ID}:${VMANGOS_GROUP_ID} /backup

COPY ./docker/database/generate-db-1.sql /docker-entrypoint-initdb.d
COPY ./docker/database/generate-db-2.sh /docker-entrypoint-initdb.d
COPY ./docker/database/regenerate-world-db.sql /sql/regenerate-world-db.sql
