#!/bin/bash

docker build --no-cache -t hub.gap.im/ops/ninja:3 .  && docker push hub.gap.im/ops/ninja:3
