Vec2 = require('justmath').Vec2

game = require './game.coffee'
view = require './view.coffee'

gameState = new game.State(new Vec2(20, 15))
gameView = new view.View(gameState)

class Loop

  constructor: (@state, @view) ->
    @pendingInput = []
    @interval = 300

  addInput: (input) ->
    @pendingInput.push input

  step: ->
    @state.processInput @pendingInput
    @pendingInput.length = 0
    @view.update()

  start: ->
    cb = =>
      @timer = setTimeout(cb, @interval)
      @step()
    cb()

  stop: ->
    clearTimeout @timer

gameLoop = new Loop(gameState, gameView)
gameLoop.start()

# Some debugging tools.
div = document.createElement 'div'
div.style.position = 'absolute'
div.style.top = '10px'
div.style.right = '10px'
document.body.appendChild div

label = document.createElement 'label'
label.textContent = gameLoop.interval + 'ms'
div.appendChild label

slider = document.createElement 'input'
slider.type = 'range'
slider.min = 1
slider.max = 500
slider.value = gameLoop.interval
slider.addEventListener 'change', ->
  gameLoop.interval = parseInt(slider.value, 10)
  label.textContent = gameLoop.interval + 'ms'
div.appendChild slider

fast = document.createElement 'button'
fast.textContent = 'Fast'
fast.addEventListener 'click', ->
  slider.value = slider.min
  event = document.createEvent 'HTMLEvents'
  event.initEvent 'change'
  slider.dispatchEvent event
div.appendChild fast

stop = document.createElement 'button'
stop.textContent = 'Stop'
stop.addEventListener 'click', ->
  gameLoop.stop()
div.appendChild stop

step = document.createElement 'button'
step.textContent = 'Step'
step.addEventListener 'click', ->
  gameLoop.step()
div.appendChild step

start = document.createElement 'button'
start.textContent = 'Play'
start.addEventListener 'click', ->
  gameLoop.start()
div.appendChild start
