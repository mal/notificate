A little notification server to help with two way http communication through a firewall.

###Features
* byte for byte retransmission to every connected client

###Limitations
* no support for picking up missed messages
* no DoS protection, connections have no timeout

###Notes
The only web browser I know to work with this in real time is Firefox (tested with 8), currently all other browsers buffer responses until a set number of bytes is received or the response is terminated. While this server is not designed with web browsers in mind, it is the most convenient way to test the system.

***

###API

    /channel/<string>
      GET
        200 - connected to existing channel
        201 - created the channel and connected
      POST
        204 - pushed data to channel stream
        404 - channel doesn't exist
      DELETE
        204 - closed channel, terminated client connections
        404 - channel doesn't exist

    /info
      GET
        200 - list existing channels
