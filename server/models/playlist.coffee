# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_data.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/27 16:26:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/07 21:47:55 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

cozydb = require 'cozydb'

module.exports = PlaylistData = cozydb.getModel 'Playlist',
    name:               type: String, default: 'New Playlist'
    tracks:             type: [String]
    creationDate:       type: String
    lastModification:   type: String
