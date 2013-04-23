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


class MapView

  constructor: (@map, @tileImage, @tileSize) ->

  draw: (ctx) ->
    @map.foreach (x, y) =>
      S = @tileSize
      tx = ty = 0 # TODO
      dx = x * S
      dy = y * S
      ctx.drawImage @tileImage, tx, ty, S, S, dx, dy, S, S

# -------------------------

canvas = document.createElement 'canvas'
canvas.width = 800
canvas.height = 400
canvas.id = 'canvas'
document.body.appendChild canvas

ctx = canvas.getContext '2d'
CHECK ctx, 'Got 2D context'

tiles = new Image()
tiles.src = 'dustycraft-tiles.png'

map = new Map(10, 10)
mapView = new MapView(map, tiles, 32)

animate = ->
  mapView.draw ctx
  requestAnimationFrame animate

requestAnimationFrame animate

# Disable delect.
document.unselectable = 'on'
document.body.style.userSelect = 'none'
document.addEventListener 'selectstart', -> false
