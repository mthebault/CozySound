# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_list.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 18:42:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/10 19:44:58 by ppeltier         ###   ########.fr        #
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

    getAlbumId: (model) ->
        if model instanceof Track
            model.get 'album'
        else
            model.album


    setAlbum: (model, album, options, callback) ->
        allOptions = _.extend({add: true, remove: false, silent: true}, options)
        model = @set model, allOptions
        model.album = album
        if not (options?.silent == true)
            @trigger 'add', model
        if callback?
            callback model


    newWorker: (albumId, queue, options, callback) ->
        window.app.albumCollection.fetchAlbumById albumId, (err, album) =>
            return console.error err if err
            queue.forEach (model) =>
                @setAlbum model, album, options, callback


    add: (models, options, callback) ->
        if !_.isArray(models)
            models = [models]

        loop
            break if models.length == 0
            model = models.pop()
            if not (model.id? and @get(model.id))
                albumId = @getAlbumId(model)
                album = window.app.albumCollection.get albumId
                if not album?
                    newQueue = []
                    newQueue.push model
                    models.forEach (modelQueue) =>
                        if albumId == @getAlbumId(modelQueue)
                            newQueue.push models.splice(models.indexOf(modelQueue), 1)[0]
                    @newWorker albumId, newQueue, options, callback
                else
                    @setAlbum model, album, options, callback


    removeTrackFromPlaylists: (model) =>
        listIds = model.get 'playlistsId'
        listPlaylists = window.app.playlistsCollection

        index = 0
        loop
            break if index >= listIds.length
            playlist = listPlaylists.get listIds[index]
            playlist.removeTrackIds model.id
            index++

    remove: (models, options) ->

        if !_.isArray(models)
            models = [models]

        index = 0
        loop
            break if index >= models.length
            @removeTrackFromPlaylists models[index]
            ret = super models[index], options
            ret.destroy
                url: "track/#{ret.id}"
            index++


    removeTracksFromSelection: =>
        selection = window.selection
        loop
            break if selection.length == 0
            model = selection.pop()
            @remove model


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
