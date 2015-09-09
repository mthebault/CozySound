# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    menu_list_view.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/09 12:31:35 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 13:41:11 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ViewCollection = require '../../../../lib/view_collection'
MenuRowView = require './menu_row_view'

module.exports = class MenuListView extends ViewCollection
    template: require '../templates/menu_list'
    el: '#tracks-menu-playlist'

    itemview: MenuRowView
    collectionEl:  '#tracks-menu-playlist-content'

    initialize: ->
        @collection = window.app.playlistsCollection
        super
