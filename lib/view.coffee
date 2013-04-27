map = require './map.coffee'

alert('Phaser not available') if not Phaser

TILE_SIZE = 32

class View

  constructor: (@state) ->
    @map = new map.Map(state.width, state.height)
    width = TILE_SIZE * @state.width
    height = TILE_SIZE * @state.height
    @game = new Phaser.Game(this, 'game', width, height, @init, @create, @draw)

  init: ->
    @game.loader.addSpriteSheet('tiles', '/images/dustycraft-tiles.png', 32, 32)
    @game.loader.load()

  create: ->
    @game.stage.canvas.className = 'game'

    @map.foreach (x, y) =>
      sprite = @game.createSprite(x * TILE_SIZE, y * TILE_SIZE, 'tiles')
      sprite.frame = 3
      @map.set x, y, sprite

  draw: ->

  update: ->


exports.View = View
