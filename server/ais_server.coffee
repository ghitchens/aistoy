net = require 'net'

# initialize these at module scope
clients = [] 
ais_feed = null
decoder_stream = null

[ cmd, script, feed_host, feed_port ] = process.argv 

start_main_server = ->
    
    main_server = net.Server (socket) ->
        clients.push socket
        socket.on 'end', ->      
            clients.splice clients.indexOf(socket), 1

    main_server.listen(59020)


connect_ais_feed = -> 
                     
    ais_feed = net.createConnection feed_host, feed_port

    ais_feed.on 'connect', ->
        console.log "connected to ais feed #{host}:#{port}"

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
        for client in clients
            client.write(decoded_data + "\n") 

# setup and go

if (feed_host and feed_port)
    connect_ais_feed()    
    connect_decoder_stream() 
    start_main_server()
else
    console.log "Usage: ais_server <feed-host> <port>"
