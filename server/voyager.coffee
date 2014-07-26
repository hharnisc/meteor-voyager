Fiber = Npm.require 'fibers'
EventEmitter = Npm.require 'events'
DDPClient = Npm.require 'ddp'

class Voyager extends EventEmitter
    constructor: (_voyagerServer, _voyagerPort, @_voyagerApiKey, useSsl, reconnectInterval) ->
        _voyagerServer ?= Meteor.settings.voyagerServer
        _voyagerPort ?= Meteor.settings.voyagerPort
        @_voyagerApiKey ?= Meteor.settings.voyagerApiKey
        useSsl ?= false
        reconnectInterval ?= 5000

        @_ddpclient = new DDPClient
            host: _voyagerServer
            port: _voyagerPort
            auto_reconnect: true
            auto_reconnect_timer: reconnectInterval
            use_ssl: useSsl
            maintain_collections: false

        @_ddpclient.connect (error) =>
            if error
                # TODO: might want to throw an exception here
                console.error "There was an error connecting to the voyager server"
                return
            # connect our server stats and start transmission
            
            Fiber(=>
                @_stats = new ServerStats()
                @startStatsTransmit()
                @_ddpclient.on "message", @onMessage
                @_ddpclient.subscribe "appEvents", [@_voyagerApiKey], (error, result) =>
                    if error
                        console.error "Could not subscribe to events - stopping stats transmission"
                        @stopStatsTransmit()
            ).run()

    startStatsTransmit: ->
        @_statsIntervalId = Meteor.setInterval =>
            @transmitStats()
        , 5000

    stopStatsTransmit: ->
        if @_statsIntervalId?
            Meteor.clearInterval(@_statsIntervalId)

    transmitStats: ->
        # TODO: assuming connected
        stats = @_stats.stats()
        stats['createdAt'] = new Date().getTime()
        @_ddpclient.call 'stats', [@_voyagerApiKey, stats], (error, result) ->
            if error
                console.error error

    log: (level, message, data) ->
        # TODO: assuming connected
        validLevels = [
            'debug'
            'info'
            'warn'
            'error'
            'critical'
        ]
        if not level or level not in validLevels
            console.error "Invalid log level"
            return

        log = 
            level: level
            createdAt: new Date().getTime()
            message: message
            data: if data then data else {}

        @_ddpclient.call 'log', [@_voyagerApiKey, log], (error, result) ->
            if error
                console.error error

    onMessage: (message) ->
        data = EJSON.parse message
        if data.msg is "added" and data.collection is "events"
            console.log "event detected"
            @emit data.fields.type, data.fields.data, data.id

    eventCompleted: (eventId) ->
        @_ddpclient.call 'eventComplete', [eventId], (error, result) ->
            if error
                console.error error
