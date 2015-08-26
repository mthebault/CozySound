# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlists_view.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 20:40:51 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 21:10:22 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ViewCollection = require '../../../lib/view_collection'
PlaylistView = require './playlist_view'

module.exports = class PlaylistsView extends  ViewCollection
    template: require './templates/playlists'
    el: '#menu-playlist'

    itemview: PlaylistView
    collectionEl: '#menu-playlist-list'

    initialize: (options) ->
        super options
