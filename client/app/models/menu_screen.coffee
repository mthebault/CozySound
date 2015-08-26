# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    left_menu.coffee                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 19:04:21 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 20:59:09 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

MenuView = require '../views/menu/menu_screen'
PlaylistList = require '../collections/playlists_list'
Playlist = require './playlist'

###
# Menu represent the left menu section. It manage the view (MenuView) and the
# playlist collection (PlaylistList)
# Menu communicate with the content section by events which trigger some action
# as print playlist / print all tracks / etc...
###
module.exports = class Menu

    currentPlaylist: null

    constructor: ->
        _.extend @, Backbone.Events

        # Create the collection of playlists
        @playlistsCollection = new PlaylistList

        # Create the view
        @view = new MenuView
            playlistsCollection: @playlistsCollection

        # Listen the creation of a new playlist triggered by the view
        @listenTo @view, 'playlist-create', @createNewPlaylist

    render: ->
        @view.render()

    ################################ EVENTS #####################################
    createNewPlaylist: ->
        console.log 'plop'
        @currentPlaylist = new Playlist
    ########################## END - EVENTS - END ###############################
