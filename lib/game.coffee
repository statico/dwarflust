aStar = require 'a-star'

map = require './map.coffee'

class Input

  constructor: (@command, @args) ->

class Dwarf

  constructor: ->
    @miningStrength = 10
    @x = 0
    @y = 0
    @target = { x: 0, y: 0 }

class Cell

  constructor: ->
    @discovered = false
    @walkable = false
    @earth = true
    @mass = 90 + Math.floor(Math.random() * 20)

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

    @dwarf = new Dwarf()
    @dwarf.x = @dwarf.target.x = Math.floor Math.random() * @width
    @dwarf.y = @dwarf.target.y = 1

  processInput: (commands) ->




exports.State = State
