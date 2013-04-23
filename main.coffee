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

  constructor: (@map, @tileImage, @tileSize, @tileScale = 1) ->

  draw: (ctx) ->
    @map.foreach (x, y) =>
      S = @tileSize
      tx = 11 # TODO
      ty = 8 # TODO
      sx = tx * S
      sy = ty * S
      D = S * @tileScale
      dx = x * D
      dy = y * D
      ctx.drawImage @tileImage, sx, sy, S, S, dx, dy, D, D

  screenToTileCoords: (mouseX, mouseY) ->
    D = @tileSize * @tileScale
    return [Math.floor(mouseX / D), Math.floor(mouseY / D)]

# -------------------------

TILE_WIDTH = 20
TILE_HEIGHT = 12
TILE_SIZE = 32

canvas = document.createElement 'canvas'
canvas.width = TILE_WIDTH * TILE_SIZE
canvas.height = TILE_HEIGHT * TILE_SIZE
canvas.id = 'canvas'
document.body.appendChild canvas

ctx = canvas.getContext '2d'
CHECK ctx, 'Got 2D context'

tiles = new Image()
tiles.src = 'dustycraft-tiles.png'

map = new Map(TILE_WIDTH, TILE_HEIGHT)
mapView = new MapView(map, tiles, TILE_SIZE)

canvas.addEventListener 'mousedown', (e) ->
  console.log 'MOUSEDOWN', mapView.screenToTileCoords(e.offsetX, e.offsetY)

animate = ->
  mapView.draw ctx
  requestAnimationFrame animate

requestAnimationFrame animate

# Disable delect.
document.unselectable = 'on'
document.body.style.userSelect = 'none'
document.addEventListener 'selectstart', -> false
