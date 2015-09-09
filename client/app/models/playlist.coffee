# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:19:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 19:11:20 by ppeltier         ###   ########.fr        #
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


    fetchTracks: ->
        remoteList = []
        listTracksId = @get 'tracks'
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
                @baseCollection.add data, (tracks) ->
                    @collection.add newData


    addToPlaylist: ->
        selection = window.selection

        listTracksId = @get 'tracks'
        loop
            break if selection.length == 0
            track = selection.pop()
            @collection.add track
            listTracksId.push track.id
        @save()
