#! /usr/bin/env ./node_modules/.bin/coffee
DurationTracker = require('../../bin/utils.coffee').DurationTracker
dur = new DurationTracker()

firstOne = dur.start "trackThis"
secondOne = dur.start "trackThis"
differentOne = dur.start "trackThisDifferently"
neverClose = dur.start "trackThisAsOpen"

setTimeout firstOne.stop, 100
setTimeout secondOne.stop, 200
setTimeout differentOne.stop, 150


whenDone = () ->
  console.log JSON.stringify(dur, null, 2)
  process.exit

setTimeout whenDone, 1000
