PriorityQueue = require 'priorityqueuejs'
aStar = require 'a-star'
Vec2 = require('justmath').Vec2

map = require './map.coffee'

randInt = (min, max) -> min + Math.floor(Math.random() * (max - min))

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
    @mass = randInt 90, 120
    @mined = false
    @baseValue = randInt 1, 50
    @contents = null
    @amount = 0

  toString: ->
    return JSON.stringify(this, null, '  ') + '\n' + \
      "attractiveness: #{ @calculateAttractiveness() }"

  calculateAttractiveness: ->
    switch @contents
      when 'gold' then return @baseValue + @amount * 500
      when 'silver' then return @baseValue + @amount * 300
      when 'copper' then return @baseValue + @amount * 150
      else return @baseValue

  makeRandom: ->
    # TODO: Make this config-driven.
    x = Math.random()
    if x > .90
      @contents = 'gold'
    else if x > .80
      @contents = 'silver'
    else if x > .70
      @contents = 'copper'
    else
      @contents = null

    if @contents
      @amount = randInt 1, 10
    else
      @amount = 0

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
    if queue.size() > 0
      return queue.deq()
    else
      return null

  processInput: (commands) ->
    # TODO: commands
    @_updateDwarf()

  _updateDwarf: ->
    mine = (cell) =>
      if cell.mineAndAssertMined @dwarf.miningStrength
        for p in @map.diagonalNeighbors cell.location
          neighbor = @map.get(p)
          if not neighbor.discovered
            neighbor.discovered = true
            neighbor.makeRandom()
        @dwarf.location.set cell.location

    # Find the most attractive cell.
    target = @dwarf.target = @findMostAttractiveCell()
    return if not target # Game over?

    # Is the dwarf already there?
    if @map.rectilinearDistance(@dwarf.location, target.location) == 1
      mine target
      return

    # Get a path from the dwarf to the attractive cell.
    path = @findPath @dwarf.location, target.location

    # Does the dwarf need to move closer?
    if path.length >= @dwarf.moveSpeed
      next = path[@dwarf.moveSpeed - 1]
      @dwarf.location.set next
      return

    # Did the dwarf move fewer tiles than his move speed? If so, he still has
    # a chance to swing his axe as part of the move.
    if path.length < @dwarf.moveSpeed
      queue = new PriorityQueue((a, b) -> b.distance - a.distance)
      for p in @map.cardinalNeighbors @dwarf.location
        distance = @map.rectilinearDistance p, target.location
        queue.enq({ distance: distance, point: p })
      cell = @map.get queue.deq().point
      mine cell if cell
      return

    return


exports.State = State
