# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:19:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 17:11:05 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PlaylistItems = require '../collections/playlist_items'
PlaylistScreen = require '../views/content/playlist_screen'

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
        if @playlistView?
            $('playlist-header').append @playlistView.el
            return

        @playlistView = new PlaylistScreen
            model: @
        @playlistView.render()

        @fetchTracks()

    addToPlaylist: ->
        selection = window.selection

        listTracksId = @get 'tracks'
        loop
            break if selection.length == 0
            track = selection.pop()
            @collection.add track
            listTracksId.push track.id
        @save()
