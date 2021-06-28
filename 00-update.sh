#!/bin/sh

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

# Replace if needed; e.g., to match your host user/group ID
user_id=1000
group_id=1000

# Replace with different client version, if required
# See https://github.com/vmangos/core#currently-supported-builds
client_version=5875

# Replace with a different world database import name in case there is an
# update
world_database_import_name=world_full_14_june_2021

script_path=$(readlink -f "$0")
repository_path=$(dirname "$script_path")

cd "$repository_path"

echo "[VMaNGOS]: Stopping potentially running containers..."

docker-compose down

echo "[VMaNGOS]: Cleaning ccache..."

rm -rf ./src/ccache/*

echo "[VMaNGOS]: Updating submodules..."

git submodule update --init --remote --recursive

echo "[VMaNGOS]: Building VMaNGOS..."

docker build \
  --build-arg VMANGOS_USER_ID=$user_id \
  --build-arg VMANGOS_GROUP_ID=$group_id \
  -t vmangos_build \
  -f ./docker/build/Dockerfile .

docker run \
  -v "$repository_path/vmangos:/vmangos" \
  -v "$repository_path/src/database:/database" \
  -v "$repository_path/src/world_database:/world_database" \
  -v "$repository_path/src/ccache:/ccache" \
  -e CCACHE_DIR=/ccache \
  -e VMANGOS_CLIENT=$client_version \
  -e VMANGOS_WORLD=$world_database_import_name \
  -e VMANGOS_THREADS=$((`nproc` > 1 ? `nproc` - 1 : 1)) \
  --rm \
  vmangos_build

if [ $(ls -l ./src/world_database | wc -l) -gt 2 ]; then
  echo "[VMaNGOS]: It looks like there is a new world database import; aborting update."
  echo "[VMaNGOS]: Please manually update by first checking the file name of the new world database import in ./src/world_database. You will need that file name (without the .sql extension!) in the following steps."
  echo "[VMaNGOS]: Then, replace occurrences of \"world_database_import_name=$world_database_import_name\" with \"world_database_import_name=<new world database import file name>\" throughout the repository."
  echo "[VMaNGOS]: After that, adjust the \"VMANGOS_WORLD\" environment variable for the vmangos_database service in docker-compose.yml too."
  echo "[VMaNGOS]: Finally, delete ./src/world_database/$world_database_import_name.sql and run 00-update-including-world-database-import.sh instead of 00-update.sh."
  echo "[VMaNGOS]: It is recommended to create a database backup before doing this."
  exit 1
fi

echo "[VMaNGOS]: Merging database migrations..."

cd ./src/core/sql/migrations
./merge.sh
cd "$repository_path"

echo "[VMaNGOS]: Rebuilding containers..."

docker-compose build

echo "[VMaNGOS]: Recreating database container..."

docker-compose up -d vmangos_database

echo "[VMaNGOS]: Waiting a minute for the database to settle..."

sleep 60

echo "[VMaNGOS]: Importing database updates..."

docker-compose exec -T vmangos_database sh -c \
  '[ -e /opt/vmangos/sql/migrations/world_db_updates.sql ] && mysql -u root -p$MYSQL_ROOT_PASSWORD mangos < /opt/vmangos/sql/migrations/world_db_updates.sql'
docker-compose exec -T vmangos_database sh -c \
  '[ -e /opt/vmangos/sql/migrations/characters_db_updates.sql ] && mysql -u root -p$MYSQL_ROOT_PASSWORD characters < /opt/vmangos/sql/migrations/characters_db_updates.sql'
docker-compose exec -T vmangos_database sh -c \
  '[ -e /opt/vmangos/sql/migrations/logon_db_updates.sql ] && mysql -u root -p$MYSQL_ROOT_PASSWORD realmd < /opt/vmangos/sql/migrations/logon_db_updates.sql'
docker-compose exec -T vmangos_database sh -c \
  '[ -e /opt/vmangos/sql/migrations/logs_db_updates.sql ] && mysql -u root -p$MYSQL_ROOT_PASSWORD realmd < /opt/vmangos/sql/migrations/logs_db_updates.sql'

echo "[VMaNGOS]: Recreating other containers..."

docker-compose up -d

echo "[VMaNGOS]: Update complete!"
