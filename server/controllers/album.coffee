# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    album.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/28 12:12:19 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/28 22:15:23 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'
Album = require './../models/album'

module.exports.set = (data, res, callback) ->

    setTrackAlbum = (trackId, albumId, callback) ->
        Track.find trackId, (err, track) ->
            return callback err if err
            track.album = albumId
            track.updateAttributes track, (err, data) ->
                data.index ["title"], (err) ->
                    return callback()


    # If it find an album with the same name, add the track,
    # update the track to add the playlist id and  update the
    # album to add the track id
    #TODO: make some rollback
    Album.search data.name, (error, albumFind) =>
        # Update the existing album
        return callback error if error
        if albumFind?
            albumFind.tracks.push data.tracks
            albumFind.updateAttributes albumFind, (err, album) ->
                setTrackAlbum data.tracks, albumFind.id, callback
        else
            # Create a new album
            trackId = data.tracks
            data.tracks = new Array(trackId)
            Album.create data, (err, newAlbum) ->
                return callback err if err
                newAlbum.index ["name"], (err) ->
                    setTrackAlbum trackId, newAlbum.id, callback
