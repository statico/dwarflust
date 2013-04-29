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
    result = @findPath [0, 1], [Math.floor(Math.random() * @width), 2]
    path = result.path
    last = path[path.length - 1]
    @dwarf.x = last[0]
    @dwarf.y = last[1]

  findPath: (start, end) ->
    return aStar
      start: start
      isEnd: (coord) -> coord[0] == end[0] and coord[1] == end[1]
      neighbor: (coord) =>
        neighbors = @map.cardinalNeighbors coord
        return (n for n in neighbors when @map.get(n[0], n[1])?.walkable)
      distance: (from, to) => @map.euclideanDistance from, to
      heuristic: (to) => @map.rectilinearDistance end, to
      hash: (coord) -> "#{ coord[0] }-#{ coord[1] }"

  processInput: (commands) ->
    # TODO




exports.State = State
