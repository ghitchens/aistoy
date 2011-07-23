
## A an experimental real time AIS display using node.js, coffeescript, raphael.js

I really wanted to learn coffee and node and raphael. Given that I work with marine
navigation, **aistoy** seemed to be a natural fit.

The **server/ais_server.coffee** script (written in coffee-script and node.js) connects
to an AIS feed (specified on the command line), and creates a second connection to an
ais decoder server, which is unfortunately currently a python script, as the ais decoder
library I found was for python (I plan to fix this if I have time some day). 

The client is a mish-mash of scripts I borrowed (hopefully with appropriate licenses)
and another coffee script that ties it all together for a nice view using google
maps and raphael.js.git







