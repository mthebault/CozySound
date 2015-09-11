# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_screen.coffee                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:14:16 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/11 15:42:39 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PlaylistView = require './views/playlist_view'
PlaylistMenuView = require './views/playlist_menu_view'
TracksListView = require './views/tracks_list_view'

module.exports = class PlaylistScreen
    skeleton: require './skeletons/playlist_skel'



    constructor: (options) ->
        @playlist = options.playlist
        @selection = window.selection

        _.extend @, Backbone.Events

        @frame = $('#content-screen')

        @frame.html @skeleton()

        @header = new PlaylistView
            playlist: @playlist

        @menu = new PlaylistMenuView

        @listenTo @menu, 'remove-current-playlist', @removePlaylist

        @tracks = new TracksListView
            collection: @playlist.collection
            selection: @selection


    render: ->
        @selection.emptySelection()
        @header.render()
        @menu.render()
        @tracks.render()
        @playlist.fetchTracks()

    attach: ->
        @selection.emptySelection()
        @frame.append @header.el
        @frame.append @menu.el
        @frame.append @tracks.el

    detach: ->
        @header.$el.detach()
        @menu.$el.detach()
        @tracks.$el.detach()


    removePlaylist: ->
        window.playlistsCollection.remove @menu
        @trigger 'playlist-end'
