
## An experimental real-time AIS display using: ##

- [coffeescript](http://coffeescript.org/)
- [nodejs](http://nodejs.org/)
- [websockets](http://dev.w3.org/html5/websockets/)  

All the cool kids are playing with these, and I wanted to see what the fuss was about. Given that I work with marine navigation, **aistoy** seemed to be a natural fit.  I also really needed something to get me immersed in javascript (I've blamed my resistance on the ugly syntax, but with coffee-script I finally relented).

### The Server ###

The **server/server.coffee** script (written in coffee-script and node.js) connects
to an AIS feed (specified on the command line), and creates a second connection to an
ais decoder server, which is unfortunately currently a python script, as the ais decoder
library I found ([libais](https://github.com/schwehr/libais)) was for python (I plan to fix this if I have time some day).   It opens a server a allowing web-socket connections which are used to stream the real-time data to the browser.

### The Client ###

The client is a quick hack for now - needs some more work, but you can get the 
idea pretty well.   I do rotation using html5 canvas and [elabels](http://econym.org.uk/gmap/elabel.htm).

### Conclusions: ###

- Coffee-script rocks the house.  Makes Javascript beautiful, fun, although
  it's more of a pain to develop in on the client side, because you have to 
  add a script to compile/referesh.
  
- Node's way of writing servers is super clean and straightforward, but
  it could use some polish (an exception brings down the server, really?)
  
- Websockets are a mess, but the socket.io library for node isn't a bad
  workaround to all the fiasco about browser support.  

### Installing ###

    requires python 2.6 and 2.7 with dev-libs (linux python and python-dev)

    install nodejs 4.1 or newer (see nodejs.org)

    install npm (see npmjs.org)
      (as root) curl http://npmjs.org/install.sh | sh

    install coffee-script
      sudo npm install coffee-script -g
  
    install & build libais and libais python extensions
      requires working c and python and python-dev
      https://github.com/schwehr/libais
      python setup.py build
      sudo python setup.py install
  
### Server Operation (in server directory) ####

    python ais_decode_server.py
    coffee ais_server.coffee
    
  




