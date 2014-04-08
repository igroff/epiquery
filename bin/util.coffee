class DurationTracker
  constructor: ->
    # map of template to start time, used to track
    # any executing requests 
    @openItems = {}
    @durationsTracked = {}

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
      delete @openItems[durationId]

  getRunningItems: ->
    @openItems

  getCompletedItems: ->
    @durationsTracked
module.exports.DurationTracker = DurationTracker
