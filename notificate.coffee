#!/bin/coffee

crypto = require 'crypto'
http = require 'http'
url = require 'url'

channels = {}
status =
    400: 'Bad Request'
    404: 'Not Found'
    405: 'Method Not Allowed'

http.createServer (req, res) ->

    res.error = (code) ->
        this.statusCode = code
        if code is 204 or req.method is 'HEAD'
            this.end()
        else
            message = status[code] ? ''
            this.setHeader 'Content-Type', 'text/plain; charset=utf-8' if message
            this.setHeader 'Content-Length', Buffer.byteLength(message)
            this.end message, 'utf-8'

    console.log req.connection.remoteAddress + '\t' + req.method + '\t' + req.url

    uri = url.parse req.url, true
    path = uri.pathname.split '/'
    path.shift()

    switch path.shift()
        when 'info'
            return res.error 405 unless req.method is 'GET'
            res.end (key for key of channels).join('\n'), 'utf-8'
        when 'channel', 'pub', 'sub'
            key = path.shift() ? uri.query.id
            return res.error 400 if not key
            return res.error 404 unless key of channels or req.method is 'GET'
            switch req.method
                when 'DELETE'
                    for hash, client of channels[key]
                        client.end()
                    delete channels[key]
                    res.error 204
                when 'GET'
                    res.setHeader 'Content-Type', 'text/plain; charset=utf-8'
                    unless key of channels
                        channels[key] = {}
                        res.statusCode = 201
                    hash = crypto.createHash('sha1').update(req.connection.remoteAddress + ':' + req.connection.remotePort + '@' + Date.now()).digest 'hex'
                    channels[key][hash] = res
                    req.addListener 'close', ->
                        delete channels[key][hash]
                        delete channels[key] unless Object.getOwnPropertyNames(channels[key]).length
                    req.connection.setTimeout 0
                when 'POST'
                    data = ''
                    req.addListener 'data', (chunk) -> data += chunk
                    req.addListener 'end', ->
                        for hash, client of channels[key]
                            client.write data
                        res.error 204
                else
                    res.error 405
        else
            res.error 404

.listen 52384
