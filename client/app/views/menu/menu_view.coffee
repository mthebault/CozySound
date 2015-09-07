# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    left_menu.coffee                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:40 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/07 20:20:44 by ppeltier         ###   ########.fr        #
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
    el: '#left-menu'

    events:
        'click #menu-playlist-new': 'createNewPlaylist'
        'click #menu-all-tracks': 'printAllTracks'

    initialize: (options) ->
        # Get the collection of playlist
        @playlistsCollection = options.playlistsCollection

        window.app.menuScreen = @


    render: ->
        super

        # Create a collection of playlist view based on the collection
        @playlistsViews = new PlaylistsView
            collection: @playlistsCollection
        @playlistsViews.render()

    createNewPlaylist: ->
        @trigger 'playlist-create'

    printAllTracks: ->
        @trigger 'content-print-allTracks'
