# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    menu_screen.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 22:17:02 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/27 16:18:24 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

MenuView = require '../views/menu/menu_view'
PlaylistsList = require '../collections/playlists_list'
Playlist = require './playlist'

###
# Menu represent the left menu section. It manage the view (MenuView) and the
# playlist collection (PlaylistList)
# Menu communicate with the content section by events which trigger some action
# as print playlist / print all tracks / etc...
###
module.exports = class Menu_Screen

    currentPlaylist: null

    constructor: ->
        _.extend @, Backbone.Events

        # Set a shortcut
        window.app.menuScreen = @

        # Create the collection of playlists
        @playlistsCollection = new PlaylistsList

        # Create the view
        @view = new MenuView
            playlistsCollection: @playlistsCollection

        # Listen the creation of a new playlist triggered by the view
        @listenTo @view, 'playlist-create', @createNewPlaylist

    render: ->
        @view.render()

    ################################ EVENTS #####################################
    createNewPlaylist: ->
        @playlistsCollection.create()

    ########################## END - EVENTS - END ###############################
