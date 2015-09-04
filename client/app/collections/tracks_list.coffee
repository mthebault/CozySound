# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_list.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 18:42:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/04 14:31:06 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'

###
# Represents a collection of tracks
# It acts as a cache when instanciate as the baseCollection
# The base collection holds ALL tracks of the application
###
module.exports = class TracksList extends Backbone.Collection
    model: Track
    url: 'track'


    # Number of tracks downloaded to each call of fetch
    sizeFrameDownload: 5

    # Set the number of tracks downloaded, each call of fetch will increment it
    # by sizeFrameDownload
    cursorFrameDownload: 0

    # Returns an existing model if a track with a similar id or a similar
    # tack is already in the queue.
    isTrackStored: (model) ->

        # first check by id
        existingTrack = @get model.get('id')

        # TODO: make the comparisons

        return existingTrack or null

    newWorker: (albumId, queue, options) ->
        window.app.albumCollection.fetchAlbumById albumId, (err, album) =>
            return console.error err if err
            queue.forEach (model) =>
                @setAlbum model, album, options


    getAlbumId: (model) ->
        if model instanceof Track
            model.get 'album'
        else
            model.album

    setAlbum: (model, album, options) ->
        @set model, options
        model.album = album
        @trigger 'add', model

    add: (models, options) ->
        if !_.isArray(models)
            models = [models]
        options = _.extend({merge: false, add: true, remove: false, silent: true}, options)

        loop
            break if models.length == 0
            model = models.pop()
            albumId = @getAlbumId(model)
            album = window.app.albumCollection.get albumId
            if not album?
                newQueue = []
                newQueue.push model
                models.forEach (modelQueue) =>
                    if albumId == @getAlbumId(modelQueue)
                        newQueue.push models.splice(models.indexOf(modelQueue), 1)[0]
                @newWorker albumId, newQueue, options
            else
                @setAlbum model, album, options

    set: (model, option) ->
        console.log 'model set: ', model
        super model, option
        console.log 'albumcollection: ', window.app.albumCollection

    # Change to fetch data by range, it ask the server to retrieve the number of
    # tracks set in sizeFrameDownload from cursorFrameDownload and in case of
    # success add the number of tracks retrieved to cursorFramDownload
    fetch: ->
        $.ajax
            url: "track/#{@cursorFrameDownload}/#{@sizeFrameDownload}"
            type: 'GET'
            error: (xhr) ->
                console.error xhr
            success: (data) =>
                @cursorFrameDownload += data.length
                @add data
