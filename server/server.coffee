net         = require 'net'
socket_io   = require 'socket.io'

# initialize these at module scope 

ais_feed        = null      # stream to source of raw ais data
decoder_stream  = null      # stream to python-based ais decoder
io              = null      # socket.io server (for websockets)

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

    decoder_stream.on 'data', (ais_data) ->
        if io 
            try
                io.sockets.emit 'ais', JSON.parse(ais_data)
            catch error
                console.log "#{error} : bad ais data received: #{ais_data}"

start_socket_io = ->

    io = socket_io.listen(58080)

    io.on 'connection', (socket) ->
      console.log "client conneted"

# main - setup and go, or print usage if needed

if (feed_host and feed_port)
    connect_ais_feed()    
    connect_decoder_stream() 
    start_socket_io()
else
    console.log "usage: ais_server <feed-host> <port>"




