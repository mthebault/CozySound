# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_screen.coffee                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:14:16 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/10 20:02:57 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PlaylistView = require './views/playlist_view'
TracksMenuView = require './views/tracks_menu_view'
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


        @tracks = new TracksListView
            collection: @playlist.collection
            selection: @selection


    render: ->
        @selection.emptySelection()
        @header.render()
        @tracks.render()
        @playlist.fetchTracks()

    attach: ->
        @selection.emptySelection()
        @frame.append @header.el
        @frame.append @tracks.el

    detach: ->
        @header.$el.detach()
        @tracks.$el.detach()

