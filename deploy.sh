#!/bin/bash
git pull origin master && kill `cat tmp/unicorn.pid` && unicorn_rails -E production -c config/unicorn.rb -D
