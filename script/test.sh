#!/bin/bash

path="$(dirname "${BASH_SOURCE}")"
source "${path}/common.sh"

set_path

cd ../build

cmake --build . --target project-coverage
if [ $? -eq 0 ]; then
    xdg-open ../coverage/index.html
fi

reset_path
