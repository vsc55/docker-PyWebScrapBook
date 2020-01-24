#!/bin/bash

docker build --squash  --network=host -t webscrapbook . --build-arg wsb_ver=0.12.0
