PriorityQueue = require 'priorityqueuejs'
aStar = require 'a-star'
Vec2 = require('justmath').Vec2

map = require './map.coffee'

class Input

  constructor: (@command, @args) ->

class Dwarf

  constructor: ->
    @miningStrength = 40
    @moveSpeed = 3
    @location = new Vec2(0, 0)
    @target = null

  toString: ->
    return JSON.stringify(this, null, '  ')

class Cell

  constructor: (@location) ->
    @discovered = false
    @walkable = false
    @earth = true
    @mass = 90 + Math.floor(Math.random() * 20)
    @mined = false

  toString: ->
    return JSON.stringify(this, null, '  ') + '\n' + \
      "attractiveness: #{ @calculateAttractiveness() }"

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
    @walkable = true if @mined
    return @mined

  calculateAttractiveness: ->
    return @mass / 150

class State

  constructor: (size) ->
    @size = new Vec2(size)
    @map = new map.Map(@size)

    @map.foreach (p) =>
      cell = new Cell(p)
      @map.set p, cell

    @map.foreachRow 0, (p) => @map.get(p).makeSky()
    @map.foreachRow 1, (p) => @map.get(p).makeSky()
    @map.foreachRow 2, (p) => @map.get(p).makeCrust()

    @dwarf = new Dwarf()
    @dwarf.location.y = 1

  findPath: (start, end) ->
    results = aStar
      start: start
      isEnd: (p) -> p.equals(end)
      neighbor: (p) =>
        neighbors = @map.cardinalNeighbors p
        return (n for n in neighbors when @map.get(n)?.walkable)
      distance: (p1, p2) => @map.euclideanDistance p1, p2
      heuristic: (p) => @map.rectilinearDistance p, end
      hash: (p) -> p.toString()
    return results.path

  findMostAttractiveCell: ->
    queue = new PriorityQueue((a, b) ->
      a.calculateAttractiveness() - b.calculateAttractiveness()
    )
    @map.foreach (p) =>
      cell = @map.get(p)
      queue.enq(cell) if cell.discovered and cell.earth and not cell.mined
    return queue.deq()

  processInput: (commands) ->
    # TODO: commands

    if not @dwarf.target
      @dwarf.target = @findMostAttractiveCell()

    cell = @dwarf.target
    distance = @map.rectilinearDistance @dwarf.location, cell.location
    if distance > 1
      # Move dwarf towards target.
      path = @findPath @dwarf.location, cell.location
      if path.length <= @dwarf.moveSpeed
        next = path[path.length - 1]
      else
        next = path[@dwarf.moveSpeed - 1]
      @dwarf.location.set next
    else
      # Dig!
      if cell.mineAndAssertMined @dwarf.miningStrength
        for p in @map.diagonalNeighbors cell.location
          neighbor = @map.get(p)
          neighbor?.discovered = true
        @dwarf.location.set cell.location
        @dwarf.target = null

    return


exports.State = State
