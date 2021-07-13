# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, softwarek
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file is for integration testing only

P_DIR="$1"

# start zookeeper
make PROJECT_DIR="$P_DIR" PROJECT_NAME="$(basename "$P_DIR")" BASE_DIR="$P_DIR"/dist -f build/Makefile docker-up

# start server
make PROJECT_DIR="$P_DIR"/backend PROJECT_NAME="$(basename "$P_DIR"/backend)" BASE_DIR="$P_DIR"/backend/dist -f build/Makefile start
make PROJECT_DIR="$P_DIR"/middle PROJECT_NAME="$(basename "$P_DIR"/middle)" CONF_CONSUMER_FILE_PATH="$P_DIR"/middle/conf/client.yml BASE_DIR="$P_DIR"/middle/dist -f build/Makefile start

# start integration testing
make PROJECT_DIR="$P_DIR"/backend PROJECT_NAME="$(basename "$P_DIR"/backend)" BASE_DIR="$P_DIR"/backend/dist -f build/Makefile integration
result=$?

make PROJECT_DIR="$P_DIR"/middle PROJECT_NAME="$(basename "$P_DIR"/middle)" BASE_DIR="$P_DIR"/middle/dist CONF_CONSUMER_FILE_PATH="$P_DIR"/middle/conf/test.yml -f build/Makefile integration
result2=$?

if [ $result -eq 0 ]; then
    result=$result2
fi

# stop server and clean
make PROJECT_DIR="$P_DIR"/backend PROJECT_NAME="$(basename "$P_DIR"/backend)" BASE_DIR="$P_DIR"/backend/dist -f build/Makefile clean
make PROJECT_DIR="$P_DIR"/middle PROJECT_NAME="$(basename "$P_DIR"/middle)" BASE_DIR="$P_DIR"/middle/dist -f build/Makefile clean

make PROJECT_DIR="$P_DIR" PROJECT_NAME="$(basename "$P_DIR")" BASE_DIR="$P_DIR"/dist -f build/Makefile docker-down

exit $result
