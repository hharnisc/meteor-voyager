EventEmitter = Npm.require 'events'

class Voyager extends EventEmitter
    constructor: (@_voyagerServer, @_voyagerApiKey) ->
        @_voyagerServer ?= Meteor.settings.voyagerServer
        @_voyagerApiKey ?= Meteor.settings.voyagerApiKey
        @_stats = new ServerStats()
        Meteor.setInterval =>
            @transmitStats()
        ,5000

    transmitStats: ->
        stats = @_stats.stats()
        console.log stats