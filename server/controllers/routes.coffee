# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    routes.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 06:48:47 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 17:18:46 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

track = require './track'

module.exports =
    'track':
        get: track.all
        post: track.create
        put: track.update


    'track/:start/:nbTracks':
        get: track.fetchRange
