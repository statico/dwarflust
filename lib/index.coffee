Vec2 = require('justmath').Vec2

game = require './game.coffee'
view = require './view.coffee'

gameState = new game.State(new Vec2(20, 15))
gameView = new view.View(gameState)

class Loop

  constructor: (@state, @view) ->
    @pendingInput = []

  addInput: (input) ->
    @pendingInput.push input

  step: ->
    @state.processInput @pendingInput
    @pendingInput.length = 0
    @view.update()

  start: ->
    cb = => @step()
    @timer = setInterval(cb, 300)

  stop: ->
    clearTimeout @timer

gameLoop = new Loop(gameState, gameView)
gameLoop.start()
