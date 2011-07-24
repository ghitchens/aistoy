net     = require 'net'
express = require "express"  
socket_io = require 'socket.io'

# initialize these at module scope 

ais_feed = null
decoder_stream = null
app = null
io = null

[ cmd, script, feed_host, feed_port ] = process.argv 
   
connect_ais_feed = -> 
                     
    ais_feed = net.createConnection feed_port, feed_host

    ais_feed.on 'connect', ->
        console.log "connected to ais feed #{feed_host}:#{feed_port}"

    ais_feed.on 'end', ->
        console.log "ais feed closed, attempting reconnection.."
        connect_ais_feed()

    ais_feed.on 'data', (raw_nmea_message) ->
        nmea_fields = raw_nmea_message.toString('utf8').split(',')
        if nmea_fields[0] == "!AIVDM"
            decoder_stream.write nmea_fields[5]


connect_decoder_stream = ->

    decoder_stream = net.createConnection 50008

    decoder_stream.on 'connect', -> 
        console.log "nmea decoder connected"

    decoder_stream.on 'end', -> 
        console.log "nmea decoder closed, attempting reconnection..."
        connect_decoder_stream()

    decoder_stream.on 'data', (decoded_data) -> 
        io.sockets.emit decoded_data

start_app = ->
    
    app = module.exports = express.createServer()
    io = socket_io.listen(app)
    
    app.configure ->
      app.set "views", __dirname + "/views"
      app.set "view engine", "jade"
      app.use express.bodyParser()
      app.use express.methodOverride()
      app.use express.cookieParser()
      app.use express.session(secret: "foobarbaz")
      app.use app.router
      app.use express.static(__dirname + "/public")

    app.configure "development", ->
      app.use express.errorHandler(
        dumpExceptions: true
        showStack: true
      )

    io.on 'connection', (socket) ->
      console.log "client conneted"

    app.configure "production", ->
      app.use express.errorHandler()

    app.get "/", (req, res) ->
      res.render "index", title: "Express"

                                             

# setup and go

if (feed_host and feed_port)
    connect_ais_feed()    
    connect_decoder_stream() 
    start_app()
else
    console.log "Usage: ais_server <feed-host> <port>"




