# this silly server is required because I didn't have time or inclination to get
# schwehr's python-plugin ais decoder to interface with nodejs.   By far the beter way
# would be to write a nodejs decoder plugin for it

import ais
import json
import SocketServer

class EchoRequestHandler(SocketServer.BaseRequestHandler):

    def handle(self):
        data = 'dummy'
        while data:
            data = self.request.recv(1024)
            clean_data=data.strip()
            if clean_data == 'bye':
                return
            try:
                decoded_ais_data = ais.decode(clean_data)
                jdump = json.dumps(decoded_ais_data)
                self.request.send(jdump)
            except:
                print "couldn't decode packet: ", clean_data
        
    def finish(self):
        print self.client_address, 'disconnected!'
        self.request.send('bye ' + str(self.client_address) + '\n')

server = SocketServer.ThreadingTCPServer(('', 50008), EchoRequestHandler)
server.serve_forever()
                                               
