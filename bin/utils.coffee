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
      # you know, if we return the duration here we can use it 
      stats.duration
    controller=
      stop: stop

  getRunningItems: -> @openItems

  getCompletedItems: -> @lastDurationTracked

  getLongestDurations: -> @longestDurations
    
module.exports.DurationTracker = DurationTracker

class MdxTransform

  replaceAll: (find, replace, str) =>
    try
      return str.replace(RegExp(find, 'g'), replace);
    catch err
      return str

  convertXmlaDataToMapNested: (obj) =>
    returnmap = {}
    cellNum = 0
    map = {}      
    colAxis = obj.axes[0];
    rowAxis = obj.axes[1];

    rowAxis.positions.forEach (position) ->
      parent = null
      fqName = '';
      vid = '';
      rowAxis.hierarchies.forEach (hierarchy) ->
        name = hierarchy.name;
        member = position[name];
        
        Object.keys(member).forEach (key) ->
          if key.indexOf('Vega')!=1
            vid = member[key]

        fqName +=  '/' + member.UName+'.['+vid+']';
        if typeof(map[fqName]) is "undefined"
          node = {};
          #node.vegaId = vid
          node.caption = MdxTransform.prototype.replaceAll('&amp;','&',member.Caption);
            
          if(parent)
            if(!parent.children)
              parent.children = [];
            node.p = parent.caption;
            parent.children.push(node);
          else 
            #console.log 'from katie adding to main map', node.caption, node.vegaId, node.parent
            returnmap[vid] = node;  
          map[fqName] = node;

        parent = map[fqName];
      
      cellValues = {};
      obj.axes[0].positions.forEach (pos) ->
        obj.axes[0].hierarchies.forEach (hier) ->
          name = hier.name
          cap = MdxTransform.prototype.replaceAll(' ', '', pos[name].Caption)
          val = obj.cells[cellNum++].Value;
          parent[cap] = val;

    return returnmap


  convertXmlaDataToMap: (obj) =>
    cellN = 0
    map = {}      
    colAxis = obj.axes[0];
    rowAxis = obj.axes[1];

    rowAxis.positions.forEach (position) ->
      parent = {}
      rowAxis.hierarchies.forEach (hierarchy) ->
        name = hierarchy.name;
        member = position[name];
        node = {}
        node.caption = MdxTransform.prototype.replaceAll('&amp;','&',member.Caption);
        Object.keys(member).forEach (key) ->
          if key.indexOf('Vega') >-1
            node.vegaId = member[key]

        if(node.vegaId)
          map[node.vegaId] = node
          parent = map[node.vegaId];
      
      obj.axes[0].positions.forEach (pos) ->
        obj.axes[0].hierarchies.forEach (hier) ->
          name = hier.name
          cap = MdxTransform.prototype.replaceAll(' ', '', pos[name].Caption)
          val = obj.cells[cellN++].Value;
          parent[cap] = val;

    return map


  convertXmlaDataToTree: (obj) =>
    tree = [];
    cell_Index = 0;
    map = {};      
    colAxis = obj.axes[0];
    rowAxis = obj.axes[1];

    rowAxis.positions.forEach (position) ->
      parent = null
      fqName = '';
      vid = '';
      rowAxis.hierarchies.forEach (hierarchy) ->
        name = hierarchy.name;
        member = position[name];
        Object.keys(member).forEach (key) ->
          if key.indexOf('Vega') >-1
            vid = member[key]

        fqName +=  '/' + member.UName+'.['+vid+']';
        if (typeof map[fqName]) is "undefined"
          node = {};
          node.caption = MdxTransform.prototype.replaceAll('&amp;','&',member.Caption);
          node.vegaId = vid;

          if(parent)
            if(!parent.children)
              parent.children = [];
            node.p = parent.caption;
            parent.children.push(node);
          else 
            tree.push(node) 
          map[fqName] = node;

        parent = map[fqName];

      obj.axes[0].positions.forEach (pos) ->
        obj.axes[0].hierarchies.forEach (hier) ->
          name = hier.name
          cap = MdxTransform.prototype.replaceAll(' ', '', pos[name].Caption)
          val = obj.cells[cell_Index++].Value;
          parent[cap] = val;
             
    #we do not want 'all' we want to see it by the parent name
    tree.forEach (node) ->
      MdxTransform.prototype.moveObjectPropertiesOfChildrenNamedAlltoParent(node); 

    return tree


  moveObjectPropertiesOfChildrenNamedAlltoParent: (node, parentNode) =>
    if !node
      return false
 
    if node.children
      node.children.forEach (childNode) ->
        moved =  MdxTransform.prototype.moveObjectPropertiesOfChildrenNamedAlltoParent(childNode, node);
        if moved
          node.children.splice(0,1); 
          #remove the 'All' child node

    if node.caption is 'All'
           #do not move all if it has more than one child
      if(node.children)  and (node.children.length > 1)
        return false;
      else
        #copy the properties to the parent
        try
          Object.keys(node).forEach (propName) ->
            if propName isnt 'caption'
              parentNode[propName] = node[propName];
        catch e
        return true 
    
    return false


module.exports.MdxTransform = MdxTransform
