alert('Phaser not available') if not Phaser

map = require './map.coffee'

TILE_SIZE = 32

Tiles =
  BLANK: 113
  DARK_DIRT: 37
  DIRT: 2
  DIRT_GRASS_ON_TOP: 3
  SELECTION: 211
  TARGET: 212
  SKY: 178

class View

  constructor: (@state) ->
    @spriteMap = new map.Map(state.width, state.height)
    width = TILE_SIZE * @state.width
    height = TILE_SIZE * @state.height
    @game = new Phaser.Game(this, 'game', width, height, @init, @create, @draw)
    window.game = @game #XXX

    @debug = document.createElement 'div'
    @debug.style.position = 'absolute'
    @debug.style.top = '10px'
    @debug.style.left = '10px'
    @debug.style.whiteSpace = 'pre'
    @debug.style.font = '10px/10px Menlo, Monaco, monospace'
    document.body.appendChild @debug

  init: ->
    @game.loader.addSpriteSheet('tiles', '/images/dustycraft-tiles.png', 32, 32)
    @game.loader.addSpriteSheet('dwarf', '/images/rpgmaker-dwarves.png', 32, 32)
    @game.loader.load()

  create: ->
    @game.stage.canvas.className = 'game'

    @spriteMap.foreach (x, y) =>
      sprite = @game.createSprite x * TILE_SIZE, y * TILE_SIZE, 'tiles'
      sprite.frame = Tiles.BLANK
      @spriteMap.set x, y, sprite

    @selection = @game.createSprite 0, 0, 'tiles'
    @selection.exists = false
    @selection.frame = Tiles.SELECTION

    @target = @game.createSprite 0, 0, 'tiles'
    @target.exists = false
    @target.frame = Tiles.TARGET

    @dwarf = @game.createSprite 0, 0, 'dwarf'
    @dwarf.animations.add 'dwarf', [0,1,2,1], 5, true
    @dwarf.animations.play 'dwarf'

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

    # Draw debug target for dwarf.
    if @state.dwarf.target
      @target.exists = true
      @target.x = @state.dwarf.target.x * TILE_SIZE
      @target.y = @state.dwarf.target.y * TILE_SIZE
    else
      @target.exists = false

    # Draw debug information about the cell.
    text = @state.dwarf.toString() + '\n\n'
    cell = @state.map.get(tx, ty)
    if cell then text += cell.toString()
    @debug.textContent = text

  update: ->
    # Update cells from game state.
    @state.map.foreach (x, y) =>
      cell = @state.map.get x, y
      sprite = @spriteMap.get x, y

      if cell.discovered
        sprite.alpha = 1
      else
        sprite.alpha = 0.6

      if cell.earth and cell.mined
        sprite.frame = Tiles.DARK_DIRT

      else if not cell.earth
        sprite.frame = Tiles.SKY

      else
        if not @state.map.get(x, y-1)?.earth
          sprite.frame = Tiles.DIRT_GRASS_ON_TOP
        else
          sprite.frame = Tiles.DIRT

    # Update dwarf
    @dwarf.x = @state.dwarf.location[0] * TILE_SIZE
    @dwarf.y = @state.dwarf.location[1] * TILE_SIZE

exports.View = View
