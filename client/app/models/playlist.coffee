# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:19:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/27 02:02:00 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PlaylistItems = require '../collections/playlist_items'

module.exports = class Playlist extends Backbone.Model
    url: 'playlist-list'

    # By default playlist name
    defaults:
        name: 'New Playlist'

    initialize: ->
        @collection = new PlaylistItems



