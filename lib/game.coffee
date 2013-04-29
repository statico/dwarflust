PriorityQueue = require 'priorityqueuejs'
aStar = require 'a-star'

map = require './map.coffee'

class Input

  constructor: (@command, @args) ->

class Dwarf

  constructor: ->
    @miningStrength = 40
    @location = [0, 0]
    @target = null

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

  mineAndAssertMined: (amount) ->
    @mass = Math.max 0, @mass - amount
    @mined = (@mass == 0)
    return @mined

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
    @dwarf.target = @findMostAttractiveCell()
    result = @findPath [0, 1], @dwarf.target.coords
    path = result.path
    last = path[path.length - 1]
    @dwarf.location = last

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
      queue.enq(cell) if cell.discovered and cell.earth and not cell.mined
    return queue.deq()

  processInput: (commands) ->
    # TODO: commands

    if @dwarf.target
      cell = @dwarf.target
      distance = @map.rectilinearDistance @dwarf.location, cell.coords
      if distance <= 1
        if cell.mineAndAssertMined @dwarf.miningStrength
          for neighbor in @map.diagonalNeighbors cell.coords
            [x, y] = neighbor
            @map.get(x, y).discovered = true
          @dwarf.target = null
          @dwarf.location[0] = cell.x
          @dwarf.location[1] = cell.y


exports.State = State
