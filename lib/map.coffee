Vec2 = require('justmath').Vec2

class Map

  constructor: (size) ->
    @size = new Vec2(size)
    @_map = new Array(@size.y)
    for i in [0...@size.y]
      @_map[i] = new Array(@size.x)

  get: (p) ->
    row = @_map[p.y]
    return null if not row?
    return row[p.x]

  set: (p, value) ->
    row = @_map[p.y]
    return null if not row?
    row[p.x] = value
    return value

  foreach: (cb) ->
    for y in [0...@size.y]
      for x in [0...@size.x]
        cb new Vec2(x, y)
    return

  foreachRow: (y, cb) ->
    for x in [0...@size.x]
      cb new Vec2(x, y)
    return

  cardinalNeighbors: (p) ->
    ret = []
    if p.x >= 0 then ret.push new Vec2(p.x-1, p.y)
    if p.y >= 0 then ret.push new Vec2(p.x, p.y-1)
    if p.x < @size.x then ret.push new Vec2(p.x+1, p.y)
    if p.y < @size.y then ret.push new Vec2(p.x, p.y+1)
    return ret

  diagonalNeighbors: (p) ->
    ret = @cardinalNeighbors p
    if p.x >= 0 and p.y >= 0 then ret.push new Vec2(p.x-1, p.y-1)
    if p.x >= 0 and p.y < @size.y then ret.push new Vec2(p.x-1, p.y+1)
    if p.x < @size.x and p.y >= 0 then ret.push new Vec2(p.x+1, p.y-1)
    if p.x < @size.x and p.y < @size.y then ret.push new Vec2(p.x+1, p.y+1)
    return ret

  euclideanDistance: (a, b) ->
    return a.dist(b)

  rectilinearDistance: (a, b) ->
    dx = b.x - a.x
    dy = b.y - a.y
    return Math.abs(dx) + Math.abs(dy)

exports.Map = Map
