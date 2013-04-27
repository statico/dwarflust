#!/usr/bin/env coffee

express = require 'express'
http = require 'http'
path = require 'path'
app = express()

app.set 'port', process.env.PORT or 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'hjs'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use require('stylus').middleware(__dirname + '/public')
app.use express.static(path.join(__dirname, 'public'))

if 'development' is app.get('env')
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.render 'index', title: 'Express'

http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')
