CHECK = (condition, message) ->
  if not condition
    console.error "CHECK FAILED: #{ message }"

class Map

  constructor: (@width, @height) ->
    @_map = new Array(@height)
    for i in [0...@width]
      @_map[i] = new Array(@width)

  get: (x, y) ->
    row = @_map[y]
    CHECK row?, "0 <= y < #{ @height }"
    cell = row[x]
    CHECK cell?, "0 <= x < #{ @width }"
    return cell

  set: (x, y, value) ->
    row = @_map[y]
    CHECK row?, "0 <= y < #{ @height }"
    row[x] = value

  foreach: (cb) ->
    for y in [0...@height]
      for x in [0...@width]
        cb x, y

  foreachRow: (y, cb) ->
    for x in [0...@width]
      cb x, y

exports.Map = Map
