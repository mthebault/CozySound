# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/27 16:21:05 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 11:34:04 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Playlist = require './../models/playlist'


create = (req, res, next) ->
    console.log req.body
    Playlist.create {}, (err, newPlaylist) ->
        return next err if err
        res.status(200).send(newPlaylist)

fetchAll = (req, res, next) ->
    Playlist.request 'all', (err, data) ->
        return next err if err
        res.status(200).send(data)

update = (req, res, next) ->
    playlist = req.body
    Playlist.find playlist.id, (err, playlistFetch) ->
        return next err if err
        playlistFetch.updateAttributes playlist, (err, newPlaylist) ->
            return next err if err
            res.status(200).send(newPlaylist)


remove = (req, res, next) ->
    Playlist.find req.params.id, (err, playlist) ->
        return next err if err
        playlist.destroy (err) ->
            return next err if err
            res.status(200).send({})

module.exports =
    create: create
    fetchAll: fetchAll
    update: update
    remove: remove
