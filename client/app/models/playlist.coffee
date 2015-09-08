# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:19:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 17:31:20 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PlaylistItems = require '../collections/playlist_items'
PlaylistView = require '../views/content/tracks/playlist_view'

module.exports = class Playlist extends Backbone.Model
    url: 'playlist-list'

    # By default playlist name
    defaults:
        name: 'New Playlist'

    playlistView: null

    initialize: ->
        @collection = new PlaylistItems


    fetchTracks: ->
        console.log 'tracks: ', @get 'tracks'


    render: ->
        console.log 'plop'
        if @playlistView?
            $('playlist-header').append @playlistView.el
            return

        @playlistView = new PlaylistView
            model: @
        @playlistView.render()
        @fetchTracks()
