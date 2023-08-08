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

# Replace if needed; e.g., to match your host user/group ID
user_id=1000
group_id=1000

# Replace with different client version, if required
# See https://github.com/vmangos/core#currently-supported-builds
client_version=5875

# Replace with a different world database import name in case there is an
# update
world_database_import_name=world_full_14_june_2021


# FIXME: Quick workaround to get this script working on macOS
if [ "$(uname)" = "Darwin" ]; then
  alias nproc="sysctl -n hw.logicalcpu"
fi

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

if test -z "$(docker images -q vmangos_extractors)"; then
  echo "[VMaNGOS]: Client data extractors not found, please run 00-install.sh first."
  exit 1
fi

echo "[VMaNGOS]: Note: Potential updates to the client data extractors' code since last running run 00-update.sh or 00-install.sh will not apply."
echo "[VMaNGOS]: Check the VMaNGOS repository for updates or, if in doubt, abort this script now, run 00-update.sh and then run this script again to ensure you are using the latest version of the client data extractors."
echo "[VMaNGOS]: Running client data extractors."
echo "[VMaNGOS]: This will take a long time..."

if [ ! -d "./src/client_data/Data" ]; then
  echo "[VMaNGOS]: Client data missing, aborting extraction."
  exit 1
fi

# Remove potentially existing data
rm -rf ./src/client_data/dbc
rm -rf ./src/client_data/maps
rm -rf ./src/client_data/mmaps
rm -rf ./src/client_data/vmaps
rm -rf ./src/client_data/Buildings
rm -rf ./src/client_data/Cameras

docker run \
  -v "$repository_path/src/client_data:/client_data" \
  --rm \
  vmangos_extractors \
  /opt/vmangos/bin/mapextractor

docker run \
  -v "$repository_path/src/client_data:/client_data" \
  --rm \
  vmangos_extractors \
  /opt/vmangos/bin/vmapextractor

docker run \
  -v "$repository_path/src/client_data:/client_data" \
  --rm \
  vmangos_extractors \
  /opt/vmangos/bin/vmap_assembler

docker run \
  -v "$repository_path/src/client_data:/client_data" \
  -v "$repository_path/src/core/contrib/mmap:/mmap_contrib" \
  --rm \
  vmangos_extractors \
  /opt/vmangos/bin/MoveMapGen --offMeshInput /mmap_contrib/offmesh.txt

# This data isn't used. Delete it to avoid confusion
rm -rf ./src/client_data/Buildings

# Remove potentially existing data
rm -rf ./src/data/*

mkdir -p "./src/data/$client_version"
mv ./src/client_data/dbc "./src/data/$client_version/"
mv ./src/client_data/maps ./src/data/
mv ./src/client_data/mmaps ./src/data/
mv ./src/client_data/vmaps ./src/data/

echo "[VMaNGOS]: Client data extraction complete!"
