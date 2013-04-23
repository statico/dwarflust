renderer = new PIXI.CanvasRenderer(800, 400)
renderer.view.id = 'canvas'
document.body.appendChild renderer.view

tilesTexture = new PIXI.Texture.fromImage 'dustycraft-tiles.png'

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

  constructor: (@map, @pixelSize) ->
    @sprites = new Map(@map.width, @map.height)
    @sprites.foreach (x, y) =>
      sprite = new PIXI.Sprite(tilesTexture)
      sprite.position.x = x * @pixelSize
      sprite.position.y = y * @pixelSize
      sprite.width = sprite.width = @pixelSize
      @sprites.set x, y, sprite

  addToStage: (stage) ->
    @sprites.foreach (x, y) =>
      stage.addChild @sprites.get(x, y)

# -------------------------

map = new Map(10, 10)
mapView = new MapView(map, 32)
stage = new PIXI.Stage(0x000000, true)
mapView.addToStage stage

animate = ->
  renderer.render stage
  requestAnimationFrame animate

requestAnimationFrame animate

$(document)
  .attr('unselectable', 'on')
  .css('user-select', 'none')
  .on('selectstart', false)

