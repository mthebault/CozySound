# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    left_menu.coffee                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:40 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 13:16:58 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../lib/base_view'
PlaylistsListView = require './playlist/playlists_list_view'

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
        'click #menu-queue': 'printQueue'

    initialize: ->
        # Get the collection of playlist
        @playlistsCollection = window.app.playlistsCollection

        window.app.menuScreen = @


    afterRender: ->
        # Create a collection of playlist view based on the collection
        @playlistsViews = new PlaylistsListView
            collection: @playlistsCollection
        @playlistsViews.render()


    createNewPlaylist: ->
        @trigger 'playlist-create'


    printAllTracks: ->
        @trigger 'content-print-allTracks'

    printQueue: ->
        @trigger 'content-print-queue'
