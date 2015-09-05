# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    album.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/28 12:12:19 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/03 19:38:15 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Album = require './../models/album'
moment = require 'moment'

albumAttributes = ['name', 'genre', 'year', 'artist', 'feat']

now = moment().toISOString()

fetchAll = (req, res, next) ->
    Album.request 'all', (err, data) ->
        return next err if err
        res.status(200).send(data)

getByName = (req, res, next) ->
    Album.search req.params.name, (err, album) ->
        return next err if err
        if album?
            res.status(200).send(album)
        else
            res.status(200).send({})


getById = (req, res, next) ->
    Album.find req.params.id, (err, album) ->
        return next err if err
        if album?
            res.status(200).send(album)
        else
            res.status(200).send({})


# Create a new album
create = (req, res, next) ->
    data = req.body
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


#TODO: update requests for more specific request, too much potential shit coulb
#be update with this way
update = (req, res, next) ->
    album = req.body
    Album.find album.id, (err, albumFetch) ->
        return next err if err
        albumFetch.updateAttributes album, (err, newAlbum) ->
            return next err if err
            res.status(200).send(newAlbum)



module.exports =
    create: create
    getByName: getByName
    getById: getById
    update: update
    fetchAll: fetchAll
