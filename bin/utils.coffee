class DurationTracker
  constructor: ->
    @totalStarts = 0
    @totalStops = 0
    # all the folowing items are statistics tracked by duration id
    #
    # items that we're actively keeping track of i.e. durationIds
    # for which we've had a start call, but no stop
    @openItems = {}
    @startCounts = {}
    @stopCounts = {}
    @lastDurationTracked = {}
    @longestDurations = {}

  start: (durationId) =>
    if not @startCounts.hasOwnProperty durationId
      @startCounts[durationId] = 0
    # if we don't have one, we'll start tracking it at 1
    if not @openItems.hasOwnProperty durationId
      @openItems[durationId] = 0
    @totalStarts++
    @startCounts[durationId]++
    @openItems[durationId]++
    startTime = Date.now()

    stop = () =>
      if not @stopCounts.hasOwnProperty durationId
        @stopCounts[durationId] = 0
      endTime = Date.now()
      stats =
        startTime: startTime
        endTime:   endTime
        duration:  endTime - startTime
      # now we track this in our longest map, if it's longer than the one there
      if @longestDurations.hasOwnProperty durationId
        @longestDurations[durationId] = stats if stats.duration > @longestDurations[durationId].duration
      else
        @longestDurations[durationId] = stats

      if --@openItems[durationId] is 0
        delete @openItems[durationId]

      @lastDurationTracked[durationId] = stats
      @totalStops++
      @stopCounts[durationId]++
      null # yeah, really nothing returned
    controller=
      stop: stop

  getRunningItems: -> @openItems

  getCompletedItems: -> @lastDurationTracked

  getLongestDurations: -> @longestDurations
    
module.exports.DurationTracker = DurationTracker
