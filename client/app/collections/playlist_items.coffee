# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 19:48:45 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 20:33:24 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require '../models/track'

module.exports = class PlaylistItems extends Backbone.Collection
    url: 'playlist'
    model: Track
