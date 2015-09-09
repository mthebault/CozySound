# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    routes.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 06:48:47 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 17:03:21 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

track = require './track'
playlist = require './playlist'
album = require './album'

module.exports =
    'track':
        get: track.all
        post: track.create
        put: track.update

    'track/:start/:nbTracks':
        get: track.fetchRange

    'playlist-list':
        post: playlist.create
        get: playlist.fetchAll
        put: playlist.update

    'album/name/:name':
        get: album.getByName

    'album/:id':
        get: album.getById


    'album':
        get: album.fetchAll
        post: album.create
        put: album.update
