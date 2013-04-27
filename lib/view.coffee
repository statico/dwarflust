alert('Phaser not available') if not Phaser

map = require './map.coffee'

TILE_SIZE = 32

TILESET_URL = '/images/dustycraft-tiles.png'

TILES =
  BLANK: 113
  DARK_DIRT: 38
  DIRT: 2
  DIRT_GRASS_ON_TOP: 3
  SELECTION: 211
  SKY: 178


class View

  constructor: (@state) ->
    @spriteMap = new map.Map(state.width, state.height)
    width = TILE_SIZE * @state.width
    height = TILE_SIZE * @state.height
    @game = new Phaser.Game(this, 'game', width, height, @init, @create, @draw)
    window.game = @game #XXX

  init: ->
    @game.loader.addSpriteSheet('tiles', TILESET_URL, 32, 32)
    @game.loader.load()

  create: ->
    @game.stage.canvas.className = 'game'

    @spriteMap.foreach (x, y) =>
      sprite = @game.createSprite x * TILE_SIZE, y * TILE_SIZE, 'tiles'
      sprite.frame = TILES.BLANK
      @spriteMap.set x, y, sprite

    @selection = @game.createSprite 0, 0, 'tiles'
    @selection.exists = false
    @selection.frame = TILES.SELECTION

    @game.input.onDown.add ->
      console.log 'XXX', 'down'

  draw: ->
    # Update cursor position.
    x = @game.input.x - @game.stage.canvas.offsetLeft
    y = @game.input.y - @game.stage.canvas.offsetTop
    tx = Math.floor(x / TILE_SIZE)
    ty = Math.floor(y / TILE_SIZE)
    @selection.x = tx * TILE_SIZE
    @selection.y = ty * TILE_SIZE
    @selection.exists = true
    @selection.alpha = if @game.input.mouse.isDown then 0.9 else 0.5

  update: ->
    # Update cells from game state.
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
