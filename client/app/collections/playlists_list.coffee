# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlists_list.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:16:29 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 20:33:41 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Playlist = require '../models/playlist'

module.exports = class PlaylistList extends Backbone.Collection
    model: Playlist
    url: 'playlist-list'
