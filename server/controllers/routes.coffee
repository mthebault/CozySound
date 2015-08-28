# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    routes.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 06:48:47 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/27 16:26:42 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

track = require './track'
playlist = require './playlist'

module.exports =
    'track':
        get: track.all
        post: track.create
        put: track.update


    'track/:start/:nbTracks':
        get: track.fetchRange

    'playlist-list':
        post: playlist.create
