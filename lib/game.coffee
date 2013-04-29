PriorityQueue = require 'priorityqueuejs'
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

  constructor: (@x, @y) ->
    @coords = [@x, @y]
    @discovered = false
    @walkable = false
    @earth = true
    @mass = 90 + Math.floor(Math.random() * 20)
    @mined = false

  makeSky: ->
    @discovered = true
    @walkable = true
    @earth = false
    @mined = true

  makeCrust: ->
    @discovered = true

  mineAndAssertMass: (amount) ->
    @mass = Math.max 0, @mass - amount
    return @mass > 0

  calculateAttractiveness: ->
    return @mass / 150

class State

  constructor: (@width, @height) ->
    @map = new map.Map(@width, @height)

    @map.foreach (x, y) =>
      cell = new Cell(x, y)
      @map.set x, y, cell

    @map.foreachRow 0, (x, y) => @map.get(x, y).makeSky()
    @map.foreachRow 1, (x, y) => @map.get(x, y).makeSky()
    @map.foreachRow 2, (x, y) => @map.get(x, y).makeCrust()

    @dwarf = new Dwarf()
    target = @findMostAttractiveCell()
    result = @findPath [0, 1], target.coords
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

  findMostAttractiveCell: ->
    queue = new PriorityQueue((a, b) ->
      a.calculateAttractiveness() - b.calculateAttractiveness()
    )
    @map.foreach (x, y) =>
      cell = @map.get(x, y)
      queue.enq(cell) if cell.discovered
    return queue.deq()

  processInput: (commands) ->
    # TODO




exports.State = State
