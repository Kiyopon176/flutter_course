#!/usr/bin/env bash
# The layer rule: dependencies point down.
#   screens -> models -> repositories -> core/api -> the world
# Run from the project root before every commit. Prints nothing when the rule holds.
cd "$(dirname "$0")/.." || exit 2

# 1. package:http only in core/api and in *_repository.dart
http=$(grep -rl "package:http" lib/ | grep -v -e core/api -e _repository.dart)

# 2. package:flutter/material never in a model, a repository or core/api
material=$(grep -rl "package:flutter/material" lib/ | grep -e _model.dart -e _repository.dart -e core/api)

# 3. the real repository is constructed in one place only: main.dart
#    (its own constructor declaration does not count)
newrepo=$(grep -rn "HttpUserRepository(" lib/ | grep -v -e "^lib/main.dart:" -e "HttpUserRepository(this\.")

[ -n "$http" ] && echo "$http"
[ -n "$material" ] && echo "$material"
[ -n "$newrepo" ] && echo "$newrepo"
[ -z "$http" ] && [ -z "$material" ] && [ -z "$newrepo" ]
