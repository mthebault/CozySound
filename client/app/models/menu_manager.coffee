# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    menu_manager.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:07:41 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 12:05:53 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

MenuView = require '../views/menu/menu_view'
Playlist = require './playlist'

###
# Menu represent the left menu section. It manage the view (MenuView) and the
# playlist collection (PlaylistList)
# Menu communicate with the content section by events which trigger some action
# as print playlist / print all tracks / etc...
###
module.exports = class MenuManager

    currentPlaylist: null

    constructor: ->
        _.extend @, Backbone.Events

        @playlistsCollection =  window.app.playlistsCollection

        # Set a shortcut
        window.app.menuScreen = @

        # Create the view
        @menuView = new MenuView

        # Listen the creation of a new playlist triggered by the view
        @listenTo @menuView, 'playlist-create', @createNewPlaylist

    render: ->
        @menuView.render()

    ################################ EVENTS #####################################
    createNewPlaylist: ->
        @playlistsCollection.create()

    ########################## END - EVENTS - END ###############################
