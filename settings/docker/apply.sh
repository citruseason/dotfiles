#!/usr/bin/env bash

docker-machine create default

docker-machine restart default

sh -c "echo 'eval $(docker-machine env default) >> ~/.zshrc'"
