A little streaming echo server written for performance testing.

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
