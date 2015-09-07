# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/27 16:21:05 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/07 21:48:42 by ppeltier         ###   ########.fr        #
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

module.exports =
    create: create
    fetchAll: fetchAll
