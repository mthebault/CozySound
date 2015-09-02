# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    album_list.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/02 11:16:41 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/02 13:20:24 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Album = require '../models/album'

module.exports = class AlbumList extends Backbone.Collection
    url: 'album'
    model: Album


    createAlbum: (model, callback) ->
        $.ajax
            url: "album/#{model.get 'album'}"
            type: 'GET'
            error: (xhr) ->
                console.error xhr
            success: (album) =>
                console.log 'response: ', album
                if album?.name
                    console.log 'Album exist'
                else
                    console.log 'Album NO exist'
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
                            album = newAlbum
                            model.unset 'artist', 'silent'
                            model.unset 'year', 'silent'
                            model.unset 'genre', 'silent'
                            model.set 'album', newAlbum.id
                            console.log 'model after: ', model
                            console.log 'Album Collection: ', @
                            callback null, model

    upload: (model, callback) ->
        console.log 'DATA: ', model
        album = @findWhere
            name: model.get 'album'
        if not album?
            @createAlbum model, (err, album) ->

