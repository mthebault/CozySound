# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    routes.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 06:48:47 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 10:20:44 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

track = require './track'

module.exports =
    'track':
        post: track.create
        put: track.update

    'tracks':
        get: track.all

    'tracks/:start/:nbTracks':
        get: track.fetchRange
