# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:19:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/10 20:01:53 by ppeltier         ###   ########.fr        #
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


    removeTrackIds: (listTrackIds, options) ->
        if !_.isArray(listTrackIds)
            listTrackIds = [listTrackIds]

        tracksId = @get 'tracksId'

        index = 0
        loop
            console.log 'index remove tracks ids loop: ', index
            break if index >= listTrackIds.length
            modelIndex = tracksId.findIndex (elem) =>
                elem is listTrackIds[index]
            tracksId = tracksId.splice modelIndex, 1
            index++

        @save {tracksId: tracksId}
        @collection.remove listTrackIds, options


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

