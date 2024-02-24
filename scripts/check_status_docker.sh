#!/bin/bash
id=$(docker container ls -q -f "status=exited")
docker start $id
