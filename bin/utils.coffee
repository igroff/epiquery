class DurationTracker
  constructor: ->
    # items that we're actively keeping track of i.e. durationIds
    # for which we've had a start call, but no stop
    @openItems = {}
    # map of most recent duration data we have for a given durationId
    # this is updated on a stop call, so we can have none of these if
    # we're tracknig things and no stop callas have been made
    @durationsTracked = {}
    # map of longest duration seen by durationId
    @longestDurations = {}

  start: (durationId) ->
    # we'll only start tracking if we're not already doing so for a 
    # given durationId
    if not @openItems.hasOwnProperty durationId
      # we'll store our start time
      @openItems[durationId]= Date.now()

  stop: (durationId) ->
    if @openItems.hasOwnProperty durationId
      @durationsTracked[durationId]=
        startTime: @openItems[durationId]
        endTime: Date.now()
      stats = @durationsTracked[durationId]
      stats.duration = stats.endTime - stats.startTime
      # now we track this in our longest map, if it's longer than the one there
      if @longestDurations.hasOwnProperty durationId
        @longestDurations[durationId] = stats if stats.duration > @longestDurations[durationId].duration
      else
        @longestDurations[durationId] = stats
      delete @openItems[durationId]

  getRunningItems: -> @openItems

  getCompletedItems: -> @durationsTracked

  getLongestDurations: -> @longestDurations
    
module.exports.DurationTracker = DurationTracker
