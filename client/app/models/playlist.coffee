# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:19:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/10 22:56:51 by ppeltier         ###   ########.fr        #
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
        @baseCollection = window.app.baseCollection
        @selection = window.selection


    fetchTracks: ->
        remoteList = []
        listTracksId = @get 'tracksId'
        listTracksId.forEach (id) =>
            track = @baseCollection.get id
            if track
                @collection.push track
            else
                remoteList.push id
        if remoteList.length > 0
            @fetchRemoteTracks remoteList

    fetchRemoteTracks: (listId) ->
        $.ajax
            url: "tracks/fetch"
            data: {listId: listId}
            type: 'GET'
            error: (xhr) ->
                console.error xhr
            success: (data) =>
                @baseCollection.add data, null, (tracks) =>
                    @collection.add tracks


    removeTrackId: (trackId, options) ->
        playlistTracksId = @get 'tracksId'

        modelIndex = playlistTracksId.findIndex (elem) => elem is trackId
        playlistTracksId.splice modelIndex, 1

        @save {tracksId: playlistTracksId}
        @collection.remove trackId, options


    addToPlaylist: ->

        listTracksId = @get 'tracksId'
        loop
            break if @selection.length == 0
            track = @selection.pop()

            if not (_.find listTracksId, (elem) -> elem is track.id)
                @collection.add track
                listTracksId.push track.id
                track.addPlaylist @
        @save 'tracksId', listTracksId

