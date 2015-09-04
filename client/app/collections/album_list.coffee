# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    album_list.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/02 11:16:41 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/04 14:24:45 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Album = require '../models/album'

module.exports = class AlbumList extends Backbone.Collection
    url: 'album'
    model: Album

    @ATTRIBUTES: ['name', 'genre', 'year', 'artist', 'feat']


    initialize: ->
        @albumQueue = async.queue @upload, 1


    fetchAlbumByName: (albumName, callback) =>
        $.ajax
            url: "album/name/#{albumName}"
            type: 'GET'
            error: (error) =>
                callback error
            success: (album) =>
                @add album
                callback null, @get(album.id)

    fetchAlbumById: (albumId, callback) ->
        $.ajax
            url: "album/#{albumId}"
            type: 'GET'
            error: (error) ->
                callback error
            success: (album) =>
                @add album
                callback null, @get(album.id)

    createAlbum: (model, callback) ->
        album = new Album
            name: model.get 'album'
            artist: model.get 'artist'
            year: model.get 'year'
            genre: model.get 'genre'
        @.sync 'create', album,
            error: (res) ->
                console.error error
            success: (newAlbum) =>
                @add newAlbum
                model.unset 'artist', 'silent'
                model.unset 'year', 'silent'
                model.unset 'genre', 'silent'
                model.set 'album', newAlbum.id
                callback null, model


    checkRemoteAlbum: (model, callback) ->
        @fetchAlbumByName model.get('album'), (err, album) =>
            return console.error err if err
            if album?.name
                @add album
                album = @get album.id
                track = @mergeDataAlbum album, model
                callback null, track
            else
                @createAlbum model, callback


    mergeDataAlbum: (album, model) ->
        AlbumList.ATTRIBUTES.forEach (elem) ->
            elemModel = model.get elem
            elemAlbum = album.get elem
            if elemModel?
                if elemModel == elemAlbum
                    model.unset elem, 'silent'
                else if not elemAlbum?
                    elemAlbum = elemModel
                    model.unset elem, 'silent'
        # else the track attribute is differente of album same
        # attribute we keep it in the track and that will overprint the
        # album data
        model.set 'album', album.id
        model


    addTrackToAlbum: (track, callback) ->
        album = @get track.get('album')
        tracks = album.get 'tracks'
        tracks.push track.id
        #TODO: make a specifique request for adding a track, too much potential
        #shit could be update with this way
        album.sync 'update', album,
            error: (xhr) ->
                console.error 'ERROR: ', xhr


    lauchTrackUpload: (track) ->
        window.app.uploadQueue.trackQueue.push track
        # Add to the upload collection so it can be processed
        #window.app.uploadQueue.uploadCollection.add track


    upload: (model, next) =>
        album = @findWhere
            name: model.get 'album'
        if not album?
            @checkRemoteAlbum model, (err, track) =>
                return console.error err if err
                @lauchTrackUpload track
                next()
        else
            track = @mergeDataAlbum album, model
            @lauchTrackUpload track
            next()
