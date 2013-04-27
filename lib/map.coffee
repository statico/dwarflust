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

exports.Map = Map
