# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_menu_list_view.coffee                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/11 14:50:44 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/11 14:59:50 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


ViewCollection = require '../../../../../lib/view_collection'
MenuRowView = require './tracks_menu_row_view'

module.exports = class TracksMenuListView extends ViewCollection
    template: require '../../templates/tracks_menu/tracks_menu_list'
    el: '#tracks-menu-playlist'

    itemview: MenuRowView
    collectionEl:  '#tracks-menu-playlist-content'

    initialize: ->
        @collection = window.app.playlistsCollection
        super
