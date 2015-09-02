# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    album.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/28 12:12:19 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/02 13:17:17 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'
Album = require './../models/album'
moment = require 'moment'

albumAttributes = ['name', 'genre', 'year', 'artist', 'feat']

now = moment().toISOString()

get = (req, res, next) ->
    Album.search req.params.name, (err, album) ->
        return next err if err
        if album?
            res.status(200).send(album)
        else
            res.status(200).send(null)

# Create a new album
create = (req, res, next) ->
    data = req.body
    console.log 'data: ', data
    dataAlbum =
        name: data.name
        artist: data.artist
        year: data.year
        genre: data.genre
        creationDate: now
        lastModification: now
        tracks: []

    Album.create dataAlbum, (err, newAlbum) ->
        return next err if err
        newAlbum.index ["name"], (err) ->
            console.error err if err
            res.status(200).send(newAlbum)



#updateAlbum = (album, data, callback) ->
    #trackData =
        #title: data.title
        #trackNb: data.trackNb
        #time: data.time
        #size: data.size
        #docType: data.docType
        #album: album.id
        #uploading: true
        #creationDate: now
        #lastModification: now
        #plays: 0

    #albumAttributes.forEach (elem) ->
        #if album[elem]? && data[elem] && album[elem] != album[elem]
            #trackData[elem] = data[elem]

    ## Add the track to the list of album tracks
    #album.tracks.push data.tracks

    ## Update album
    #album.updateAttributes album, (err, album) ->
        #return callback err if err
        ## Set the album in the track
        #trackData.album = album.id
        #return callback null, trackData




## If it find an album with the same name, add the track,
## update the track to add the playlist id and  update the
## album to add the track id
##TODO: make some rollback
#create = (data, callback) ->
    ## If we can find an album with the same name
    #Album.search data.album, (error, albumFind) =>
        #return callback error if error
        #if albumFind?
            #console.log 'updateAlbum'
            ## Update the existing album
            #updateAlbum albumFind, data, callback
        #else
            #console.log 'createAlbum'
            ## Create a new album
            #createAlbum data, (err, newAlbum) ->
                #return callback err if err
                #dataTrack =
                    #title: data.title
                    #trackNb: data.trackNb
                    #time: data.time
                    #size: data.size
                    #docType: data.docType
                    #album: newAlbum.id
                    #uploading: true
                    #creationDate: now
                    #lastModification: now
                    #plays: 0

                #callback null, dataTrack



#addTrack = (albumId, trackId, callback) ->
    #Album.find albumId, (err, albumFind) ->
        #return callback err if err
        #albumFind.tracks.push trackId
        #albumFind.updateAttributes albumFind, callback



module.exports =
    create: create
    get: get
