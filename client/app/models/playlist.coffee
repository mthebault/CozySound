# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:19:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/07 21:49:22 by ppeltier         ###   ########.fr        #
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
