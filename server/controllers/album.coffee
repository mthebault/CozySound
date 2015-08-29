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

albumAttributes = ['name', 'genre', 'year', 'artist', 'feat']

updateAlbum = (album, data, callback) ->
    trackData = {}
    albumAttributes.forEach (elem) ->
        console.log 'album: ', album[elem]
        if album[elem]? && data[elem] && album[elem] != album[elem]
            trackData[elem] = data[elem]

    # Add the track to the list of album tracks
    album.tracks.push data.tracks

    # Update album
    album.updateAttributes albumFind, (err, album) ->
        return callback err if err
        # Set the album in the track
        trackData.album = album.id
        return callback null, trackData


# Create a new album
createAlbum = (data, callback) ->
    trackId = data.tracks
    data.tracks = new Array(trackId)
    Album.create data, (err, newAlbum) ->
        return callback err if err
        newAlbum.index ["name"], (err) ->


# If it find an album with the same name, add the track,
# update the track to add the playlist id and  update the
# album to add the track id
#TODO: make some rollback
set = (data, callback) ->
    # If we can find an album with the same name
    Album.search data.albumName, (error, albumFind) =>
        return callback error if error
        if albumFind?
            # Update the existing album
            updateAlbum albumFind, data, callback
        else
            # Create a new album
            createAlbum data, callback

module.exports =
    set: set
