#!/bin/bash -u

# Copyright 2018 ConsenSys AG.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

NO_LOCK_REQUIRED=true

. ./.env
. ./.common.sh


PARAMS=""

displayUsage()
{
  echo "This script creates and start a local private Besu IBFT2 network using Docker."
  echo "Usage: ${me} [OPTIONS]"
  echo "    -e                       : setup ELK with the network."
  exit 0
}

composeFile="docker-compose_poa"

while getopts "he" o; do
  case "${o}" in
    h)
      displayUsage
      ;;
    e)
      composeFile="docker-compose_elk_poa"
      ;;
    *)
      displayUsage
    ;;
  esac
done

composeFile="-f ${composeFile}.yml"

# Build and run containers and network
echo "${composeFile}" > ${LOCK_FILE}
echo "${SAMPLE_VERSION}" >> ${LOCK_FILE}

echo "${bold}*************************************"
echo "Sample Network for Besu at ${SAMPLE_VERSION}"
echo "*************************************${normal}"
echo "Start network"
echo "--------------------"

echo "Starting network..."
docker compose ${composeFile} build --pull
docker compose ${composeFile} up --detach

#list services and endpoints
./list.sh
