# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    routes.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 06:48:47 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/25 22:56:27 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

track = require './track'

module.exports =
    'track':
        post: track.create

    'tracks':
        get: track.all
        put: track.update

    'tracks/:start/:nbTracks':
        get: track.fetchRange
