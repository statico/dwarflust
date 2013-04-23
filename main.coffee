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

  constructor: (@map, @tileImage, @pixelSize, @scale = 1) ->
    @screenSize = @pixelSize * @scale
    @init()

  init: ->

  tileToScreenCoords: (tileX, tileY) ->
    D = @screenSize
    return [tileX * D, tileY * D]

  screenToTileCoords: (mouseX, mouseY) ->
    D = @screenSize
    return [Math.floor(mouseX / D), Math.floor(mouseY / D)]

class TileMapView extends MapView

  draw: (ctx) ->
    @map.foreach (x, y) =>
      S = @pixelSize
      tx = 11 # TODO
      ty = 8 # TODO
      sx = tx * S
      sy = ty * S
      D = @screenSize
      dx = x * D
      dy = y * D
      ctx.drawImage @tileImage, sx, sy, S, S, dx, dy, D, D

class HoverMapView extends MapView

  init: ->
    super()
    @location = null
    @pressed = false
    @color = 'cyan'

  hover: (screenX, screenY) ->
    @location = @screenToTileCoords(screenX, screenY)

  blur: (screenX, screenY) ->
    @location = null

  up: ->
    @pressed = false

  down: ->
    @pressed = true

  draw: (ctx) ->
    return if @location == null

    oldAlpha = ctx.globalAlpha
    if @pressed
      ctx.globalAlpha = 0.7
    else
      ctx.globalAlpha = 0.3

    corner = @tileToScreenCoords @location[0], @location[1]

    ctx.fillStyle = @color
    ctx.fillRect corner[0], corner[1], @screenSize, @screenSize

    ctx.globalAlpha = oldAlpha


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
tileMapView = new TileMapView(map, tiles, TILE_SIZE)
hoverMapView = new HoverMapView(map, tiles, TILE_SIZE)

canvas.addEventListener 'mousedown', (e) ->
  hoverMapView.down(e.offsetX, e.offsetY)
  return false

canvas.addEventListener 'mouseup', (e) ->
  hoverMapView.up(e.offsetX, e.offsetY)
  return false

canvas.addEventListener 'mousemove', (e) ->
  hoverMapView.hover(e.offsetX, e.offsetY)
  return false

canvas.addEventListener 'mouseleave', (e) ->
  hoverMapView.blur()
  return false

animate = ->
  tileMapView.draw ctx
  hoverMapView.draw ctx
  requestAnimationFrame animate

requestAnimationFrame animate

# Disable delect.
document.unselectable = 'on'
document.body.style.userSelect = 'none'
document.addEventListener 'selectstart', -> false
