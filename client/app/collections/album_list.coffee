# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    album_list.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/02 11:16:41 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/02 19:18:06 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Album = require '../models/album'

module.exports = class AlbumList extends Backbone.Collection
    url: 'album'
    model: Album

    @ATTRIBUTES: ['name', 'genre', 'year', 'artist', 'feat']


    initialize: ->
        @albumQueue = async.queue @upload, 1



    createAlbum: (model, callback) ->
        $.ajax
            url: "album/#{model.get 'album'}"
            type: 'GET'
            error: (xhr) ->
                console.error xhr
            success: (album) =>
                if album?.name
                    @add album
                    album = @get album.id
                    track = @mergeDataAlbum album, model
                    callback null, track
                else
                    album = new Album
                        name: model.get 'album'
                        artist: model.get 'artist'
                        year: model.get 'year'
                        genre: model.get 'genre'
                    @.sync 'create', album,
                        error: (res) ->
                            console.log error
                        success: (newAlbum) =>
                            @add newAlbum
                            model.unset 'artist', 'silent'
                            model.unset 'year', 'silent'
                            model.unset 'genre', 'silent'
                            model.set 'album', newAlbum.id
                            callback null, model


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

        return model


    addTrackToAlbum: (track, callback) ->
        album = @get(track.get 'album')
        tracks = album.get 'tracks'
        tracks.push track.id
        #TODO: make a specifique request for adding a track, too much potential
        #shit could be update with this way
        album.sync 'update', album,
            error: (xhr) ->
                console.error 'ERROR: ', xhr


    upload: (model, next) =>
        album = @findWhere
            name: model.get 'album'
        if not album?
            @createAlbum model, (err, track) ->
                window.app.uploadQueue.trackQueue.push track
                next()
        else
            track = @mergeDataAlbum album, model
            window.app.uploadQueue.trackQueue.push track
            next()
