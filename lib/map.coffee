class Map

  constructor: (@width, @height) ->
    @_map = new Array(@height)
    for i in [0...@width]
      @_map[i] = new Array(@width)

  get: (x, y) ->
    row = @_map[y]
    return null if not row?
    return row[x]

  set: (x, y, value) ->
    row = @_map[y]
    return null if not row?
    row[x] = value

  foreach: (cb) ->
    for y in [0...@height]
      for x in [0...@width]
        cb x, y

  foreachRow: (y, cb) ->
    for x in [0...@width]
      cb x, y

  cardinalNeighbors: (x, y) ->
    ret = []
    if x >= 0 then ret.push [x-1, y]
    if y >= 0 then ret.push [x, y-1]
    if x < @width then ret.push [x+1, y]
    if y < @height then ret.push [x, y+1]
    return ret

  diagonalNeighbors: (x, y) ->
    ret = @cardinalNeighbors x, y
    if x >=0 and y >= 0 then ret.push [x-1, y-1]
    if x >=0 and y < @height then ret.push [x-1, y+1]
    if x < @width and y >= 0 then ret.push [x+1, y-1]
    if x < @width and y < @height then ret.push [x+1, y+1]
    return ret

exports.Map = Map
