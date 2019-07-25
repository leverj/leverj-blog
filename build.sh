#!/usr/bin/env bash
if [[ "$NODE_ENV" == develop ]]; then
  jekyll b -d html --config _config.yml,_dev.yml
else
  jekyll b -d html
fi
