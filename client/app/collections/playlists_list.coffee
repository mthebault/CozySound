# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlists_list.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 17:16:29 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 12:31:10 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Playlist = require '../models/playlist'

module.exports = class PlaylistList extends Backbone.Collection

    model: Playlist
    url: 'playlist-list'


    remove: (model, options) ->
        listTracksId = model.get 'tracksId'

        loop
            break if listTracksId.length == 0
            trackId = listTracksId.pop()
            track = window.app.baseCollection.get trackId
            if track?
                track.removePlaylistId model.id
        modelDel = super model, options
        modelDel.destroy
            url:  "playlist-list/#{modelDel.id}"
            error: (error) ->
                console.error error
