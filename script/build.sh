#!/bin/bash

path="$(dirname "${BASH_SOURCE}")"
source "${path}/common.sh"

set_path

cd ../build

cmake --build . --target project

reset_path
