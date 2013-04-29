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

  cardinalNeighbors: (coord) ->
    [x, y] = coord
    ret = []
    if x >= 0 then ret.push [x-1, y]
    if y >= 0 then ret.push [x, y-1]
    if x < @width then ret.push [x+1, y]
    if y < @height then ret.push [x, y+1]
    return ret

  diagonalNeighbors: (coord) ->
    [x, y] = coord
    ret = @cardinalNeighbors coord
    if x >= 0 and y >= 0 then ret.push [x-1, y-1]
    if x >= 0 and y < @height then ret.push [x-1, y+1]
    if x < @width and y >= 0 then ret.push [x+1, y-1]
    if x < @width and y < @height then ret.push [x+1, y+1]
    return ret

  euclideanDistance: (a, b) ->
    dx = b[0] - a[0]
    dy = b[1] - a[1]
    return Math.sqrt dx * dx + dy * dy

  rectilinearDistance: (a, b) ->
    dx = b[0] - a[0]
    dy = b[1] - a[1]
    return Math.abs(dx) + Math.abs(dy)

exports.Map = Map
