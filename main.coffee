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

TileSources = {}
TileSources.dusty = new Image()
TileSources.dusty.src = 'dustycraft-tiles.png'
TileSources.dwarves = new Image()
TileSources.dwarves.src = 'rpgmaker-dwarves.png'

Tiles =
  sky: ['dusty', 2, 11]
  grass: ['dusty', 3, 0]
  dirt: ['dusty', 2, 0]
  rock: ['dusty', 1, 0]
  coal: ['dusty', 2, 2]
  gold: ['dusty', 0, 2]
  silver: ['dusty', 2, 3]
  dwarf: ['dwarves', 1, 0]

class MapView

  constructor: (@map, @pixelSize, @scale = 1) ->
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
      obj = @map.get x, y

      # Background
      contents = obj.contents
      if y == 1 and contents == 'dirt' then contents = 'grass'
      tuple = Tiles[contents]
      CHECK tuple, "Tiles[#{ contents }]"
      [source, sx, sy] = tuple
      @drawTile ctx, source, sx, sy, x, y

  drawTile: (ctx, source, sx, sy, dx, dy) ->
    S = @pixelSize
    spx = sx * S
    spy = sy * S
    D = @screenSize
    dpx = dx * D
    dpy = dy * D
    CHECK source of TileSources, "TileSources[#{ source }] OK"
    img = TileSources[source]
    ctx.drawImage img, spx, spy, S, S, dpx, dpy, D, D

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

buildWorld = (width, height) ->
  map = new Map(width, height)
  map.foreach (x, y) ->
    obj =
      contents: 'dirt'
      seen: false
      dug: false

    if y == 0
      obj.contents = 'sky'
      obj.seen = true
      obj.dug = true

    if y == 1
      obj.seen = true

    map.set x, y, obj

  return map

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

map = buildWorld(TILE_WIDTH, TILE_HEIGHT)

tileMapView = new TileMapView(map, TILE_SIZE)
hoverMapView = new HoverMapView(map, TILE_SIZE)

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
