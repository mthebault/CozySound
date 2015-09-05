# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_data.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/27 16:26:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/28 10:48:16 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


cozydb = require 'cozydb'

module.exports = PlaylistData = cozydb.getModel 'Playlist'
    name:       String, default: 'New Playlist'
    tracks:     Array
