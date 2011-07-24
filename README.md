
## An experimental real-time AIS display using: ##

- [nodejs](http://nodejs.org/)
- [coffeescript](http://coffeescript.org/)
- [raphael.js](http://raphaeljs.org)
- [websockets](http://dev.w3.org/html5/websockets/)

All the cool kids are playing with these, and I wanted to see what the fuss was about. Given that I work with marine navigation, **aistoy** seemed to be a natural fit.

The **server/ais_server.coffee** script (written in coffee-script and node.js) connects
to an AIS feed (specified on the command line), and creates a second connection to an
ais decoder server, which is unfortunately currently a python script, as the ais decoder
library I found was for python (I plan to fix this if I have time some day). 

The client is a mish-mash of scripts I borrowed (hopefully with appropriate licenses)
and another coffee script that ties it all together for a nice view using google
maps and raphael.js.git

### Conclusions: ###

- Coffee-script rocks the house.  Makes Javascript beautiful, fun!
- Node's way of writing servers is super clean and straightforward
- Websockets are a mess, but the socket.io library for node isn't bad

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
    
  




