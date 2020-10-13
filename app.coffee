#!/usr/bin/env coffee

express = require 'express'
http = require 'http'
path = require 'path'
browserify = require 'browserify-middleware'
coffee = require 'coffee-script'
through = require 'through'

app = express()

DEBUG = app.get('env') == 'development'

app.set 'port', process.env.PORT or 5000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'hjs'
app.use require('stylus').middleware(__dirname + '/public')
app.use express.static(path.join(__dirname, 'public'))

compileCoffeeScript = (file) ->
  data = ''
  write = (buf) -> data += buf
  end = ->
    @queue coffee.compile(data)
    @queue null
  return through(write, end)

app.get '/index.js', browserify('lib/index.coffee', transform: [compileCoffeeScript])

app.get '/', (req, res) ->
  res.render 'index'

http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')
