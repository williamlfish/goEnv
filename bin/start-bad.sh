#!/usr/bin/env sh



set -a; . ./.bad.env

go build -o badGoEnv ./

./badGoEnv
