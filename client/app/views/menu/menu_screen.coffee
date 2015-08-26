# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    left_menu.coffee                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:40 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 22:21:02 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../lib/base_view'
PlaylistsView = require './playlist/playlists_view'

###
# MenuView represent the main panel view. His goal is trigger the changing
# of content in the tracks screen
#
# The playlists names a handle by a collection of view (PlaylistView)
###
module.exports = class MenuView extends BaseView

    template: require './templates/menu_screen'
    tagName: 'div'
    className: 'left-menu'
    el: '#left-menu'

    events:
        'click #menu-playlist-new': 'createNewPlaylist'

    initialize: (options) ->

        # Get the collection of playlist
        @playlistsCollection = options.playlistsCollection

        # Create a collection of playlist view based on the collection
        @playlistsViews = new PlaylistsView
            collection: @playlistsCollection


    render: ->
        super
        @playlistsViews.render()

    createNewPlaylist: ->
        @trigger 'playlist-create'


