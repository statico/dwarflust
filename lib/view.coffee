alert('Phaser not available') if not Phaser

Vec2 = require('justmath').Vec2

map = require './map.coffee'

TILE_SIZE = 32

Tiles =
  BLANK: 113
  DARK_DIRT: 37
  GOLD: 32
  COPPER: 33
  SILVER: 34
  RUBY: 67
  DIRT: 2
  DIRT_GRASS_ON_TOP: 3
  SELECTION: 211
  TARGET: 212
  SKY: 178

class View

  constructor: (@state) ->
    @spriteMap = new map.Map(state.size)
    @ready = false

    pixelWidth = TILE_SIZE * @state.size.x
    pixelHeight = TILE_SIZE * @state.size.y
    @game = new Phaser.Game(this, 'game', pixelWidth, pixelHeight, @init, @create, @draw)
    window.game = @game #XXX

    @debug1 = document.createElement 'div'
    @debug1.style.position = 'absolute'
    @debug1.style.top = '10px'
    @debug1.style.left = '10px'
    @debug1.style.whiteSpace = 'pre'
    @debug1.style.font = '10px/10px Menlo, Monaco, monospace'
    document.body.appendChild @debug1

    @debug2 = @debug1.cloneNode(true)
    @debug2.style.left = '200px'
    document.body.appendChild @debug2

  init: ->
    @game.loader.addSpriteSheet('tiles', '/images/dustycraft-tiles.png', 32, 32)
    @game.loader.addSpriteSheet('dwarf', '/images/rpgmaker-dwarves.png', 32, 32)
    @game.loader.load()

  create: ->
    @game.stage.canvas.className = 'game'

    @spriteMap.foreach (p) =>
      sprite = @game.createSprite p.x * TILE_SIZE, p.y * TILE_SIZE, 'tiles'
      sprite.frame = Tiles.BLANK
      @spriteMap.set p, sprite

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
      @target.x = @state.dwarf.target.location.x * TILE_SIZE
      @target.y = @state.dwarf.target.location.y * TILE_SIZE
    else
      @target.exists = false

    # Draw debug information about the cell.
    @debug1.textContent = @state.dwarf.toString()
    cell = @state.map.get(new Vec2(tx, ty))
    @debug2.textContent = if cell then cell.toString() else ''

    # Now we can start.
    @ready = true

  update: ->
    return if not @ready

    # Update cells from game state.
    @state.map.foreach (p) =>
      cell = @state.map.get(p)
      sprite = @spriteMap.get(p)

      if cell.discovered
        sprite.alpha = 1
      else
        sprite.alpha = 0.6

      if cell.earth and cell.mined
        sprite.frame = Tiles.DARK_DIRT

      else if not cell.earth
        sprite.frame = Tiles.SKY

      else
        switch cell.contents
          when 'gold' then sprite.frame = Tiles.GOLD
          when 'silver' then sprite.frame = Tiles.SILVER
          when 'copper' then sprite.frame = Tiles.COPPER
          else
            if not @state.map.get(p.clone().sub(0, 1))?.earth
              sprite.frame = Tiles.DIRT_GRASS_ON_TOP
            else
              sprite.frame = Tiles.DIRT

    # Update dwarf
    @dwarf.x = @state.dwarf.location.x * TILE_SIZE
    @dwarf.y = @state.dwarf.location.y * TILE_SIZE

exports.View = View
