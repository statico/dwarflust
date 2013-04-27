map = require './map'

class Input

  constructor: (@command, @args) ->

class Cell

  constructor: ->

class State

  constructor: (@width, @height) ->
    @map = new map.Map(@width, @height)

    @map.foreach (x, y) ->
      cell = new Cell()
      @map.set x, y, cell

    for row in [0..1]
      @map.foreachRow row, (x, y) ->
        @map.get(x, y).makeSky()

  processInput: (commands) ->


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
    @timer = setInterval(cb, 1000)

  stop: ->
    clearTimeout @timer
