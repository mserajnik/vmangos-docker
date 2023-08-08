#!/bin/sh

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

begins_with() { case $2 in "$1"*) true;; *) false;; esac; }

get_script_path() {
  if begins_with "/" "$1"; then
    echo "$1"
  else
    echo "$PWD/${1#./}"
  fi
}

repository_path=$(dirname "$(get_script_path "$0")")

cd "$repository_path"

echo "[VMaNGOS]: Stopping potentially running containers..."

docker compose down

echo "[VMaNGOS]: Recreating database container..."

docker compose up -d vmangos_database

echo "[VMaNGOS]: Waiting a minute for the database to settle..."

sleep 60

echo "[VMaNGOS]: Backing up databases..."

docker compose exec -T vmangos_database sh -c \
  'rm -rf /backup/*'
docker compose exec -T vmangos_database sh -c \
  'mysqldump -h 127.0.0.1 -u root -p$MYSQL_ROOT_PASSWORD mangos > /backup/mangos.sql'
docker compose exec -T vmangos_database sh -c \
  'mysqldump -h 127.0.0.1 -u root -p$MYSQL_ROOT_PASSWORD characters > /backup/characters.sql'
docker compose exec -T vmangos_database sh -c \
  'mysqldump -h 127.0.0.1 -u root -p$MYSQL_ROOT_PASSWORD realmd > /backup/realmd.sql'
docker compose exec -T vmangos_database sh -c \
  'chown -R $VMANGOS_USER_ID:$VMANGOS_GROUP_ID /backup'

echo "[VMaNGOS]: Recreating other containers..."

docker compose up -d

echo "[VMaNGOS]: Backup complete!"
