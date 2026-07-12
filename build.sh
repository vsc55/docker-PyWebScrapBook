#!/bin/bash

docker build --network=host -t webscrapbook .
#docker build --network=host -t webscrapbook . --build-arg wsb_ver=2.9.0
