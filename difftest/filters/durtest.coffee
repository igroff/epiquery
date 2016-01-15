#! /usr/bin/env bash
cat | sed -e 's["startTime":.*,["startTime": 3333[g' -e 's["endTime":.*,["endTime": 4444[g' -e 's["duration":.*["duration":55555[g'
