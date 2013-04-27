map = require './map.coffee'

class Input

  constructor: (@command, @args) ->

class Cell

  constructor: ->
    @discovered = false
    @walkable = false
    @earth = true

  makeSky: ->
    @discovered = true
    @walkable = true
    @earth = false


class State

  constructor: (@width, @height) ->
    @map = new map.Map(@width, @height)

    @map.foreach (x, y) =>
      cell = new Cell()
      @map.set x, y, cell

    for row in [0..1]
      @map.foreachRow row, (x, y) =>
        @map.get(x, y).makeSky()

  processInput: (commands) ->


exports.State = State
