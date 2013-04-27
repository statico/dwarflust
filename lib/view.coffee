alert('Phaser not available') if not Phaser

map = require './map.coffee'

TILE_SIZE = 32

TILESET_URL = '/images/dustycraft-tiles.png'

TILES =
  DIRT: 2
  DARK_DIRT: 38
  DIRT_GRASS_ON_TOP: 3
  SKY: 178


class View

  constructor: (@state) ->
    @spriteMap = new map.Map(state.width, state.height)
    width = TILE_SIZE * @state.width
    height = TILE_SIZE * @state.height
    @game = new Phaser.Game(this, 'game', width, height, @init, @create, @draw)

  init: ->
    @game.loader.addSpriteSheet('tiles', TILESET_URL, 32, 32)
    @game.loader.load()

  create: ->
    @game.stage.canvas.className = 'game'

    @spriteMap.foreach (x, y) =>
      sprite = @game.createSprite(x * TILE_SIZE, y * TILE_SIZE, 'tiles')
      sprite.frame = 113
      @spriteMap.set x, y, sprite

  draw: ->

  update: ->
    @state.map.foreach (x, y) =>
      cell = @state.map.get x, y
      sprite = @spriteMap.get x, y

      if not cell.earth
        sprite.frame = TILES.SKY

      else
        if not @state.map.get(x, y-1)?.earth
          sprite.frame = TILES.DIRT_GRASS_ON_TOP
        else
          sprite.frame = TILES.DIRT

exports.View = View
