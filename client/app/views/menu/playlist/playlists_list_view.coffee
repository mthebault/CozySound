# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlists_list_view.coffee                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:17:16 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 11:33:53 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ViewCollection = require '../../../lib/view_collection'
PlaylistRowView = require './playlists_row_view'

module.exports = class PlaylistsListView extends ViewCollection
    template: require './templates/playlists'
    el: '#menu-playlist'

    itemview: PlaylistRowView

    collectionEl: '#menu-playlist-list'
