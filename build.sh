#!/bin/bash

docker build --squash  --network=host -t webscrapbook .
#docker build --squash  --network=host -t webscrapbook . --build-arg wsb_ver=0.13.0
