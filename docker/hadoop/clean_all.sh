#!/bin/sh
docker ps -a | grep -v CON* | awk '{print }' | xargs docker rm
