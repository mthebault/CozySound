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
moment = require 'moment'

albumAttributes = ['name', 'genre', 'year', 'artist', 'feat']

now = moment().toISOString()

updateAlbum = (album, data, callback) ->
    trackData = {}
    albumAttributes.forEach (elem) ->
        if album[elem]? && data[elem] && album[elem] != album[elem]
            trackData[elem] = data[elem]

    # Add the track to the list of album tracks
    album.tracks.push data.tracks

    # Update album
    album.updateAttributes album, (err, album) ->
        return callback err if err
        # Set the album in the track
        trackData.album = album.id
        console.log 'trackData: ', trackData
        return callback null, trackData


# Create a new album
createAlbum = (data, callback) ->
    dataAlbum =
        name: data.album
        artist: data.artist
        year: data.year
        genre: data.genre
        tracks: []
        creationDate: now
        lastModification: now

    Album.create dataAlbum, (err, newAlbum) ->
        return callback err if err
        newAlbum.index ["name"], (err) ->
            return callback null, newAlbum


# If it find an album with the same name, add the track,
# update the track to add the playlist id and  update the
# album to add the track id
#TODO: make some rollback
set = (data, callback) ->
    console.log 'plop2'
    # If we can find an album with the same name
    Album.search data.albumName, (error, albumFind) =>
        return callback error if error
        if albumFind?
            console.log 'updateAlbum'
            # Update the existing album
            updateAlbum albumFind, data, callback
        else
            console.log 'createAlbum'
            # Create a new album
            createAlbum data, (err, newAlbum) ->
                return callback err if err
                dataTrack =
                    title: data.title
                    trackNb: data.trackNb
                    time: data.time
                    size: data.size
                    docType: data.docType
                    album: newAlbum.id
                    uploading: true
                    plays: 0

                callback null, dataTrack



addTrack = (albumId, trackId, callbback) ->
    console.log 'plop'
    Album.find albumId, (err, albumFind) ->
        return callback err if err
        albumFind.tracks.push trackId
        albumFind.updateAttributes albumFind, callback



module.exports =
    set: set
    addTrack: addTrack
