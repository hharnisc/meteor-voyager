Fiber = Npm.require 'fibers'
EventEmitter = Npm.require('events').EventEmitter

class Voyager extends EventEmitter
    constructor: (_voyagerServer, @_voyagerApiKey) ->
        _voyagerServer ?= Meteor.settings.voyagerServer
        @_voyagerApiKey ?= Meteor.settings.voyagerApiKey
        @_ddpclient = DDP.connect _voyagerServer  
        @_stats = new ServerStats()
        @startStatsTransmit()
        VoyagerEvents = new Meteor.Collection "voyagerevents", @_ddpclient
        self = @
        @_ddpclient.subscribe "serverEvents", [@_voyagerApiKey], (error, result) =>
            if error
                console.error "Could not subscribe to events - stopping stats transmission"
                @stopStatsTransmit()
            eventCursor = VoyagerEvents.find()
            eventCursor.observe
                added: (event) =>
                    @emit event.type, event._id, event.data

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

    eventCompleted: (eventId) ->
        @_ddpclient.call 'eventComplete', [@_voyagerApiKey, eventId], (error, result) ->
            if error
                console.error error
