# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    album.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/28 10:52:08 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/02 12:56:01 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

cozydb = require 'cozydb'

module.exports = Album = cozydb.getModel 'Album',
    name:   		type: String
    artist: 		type: String
    year:   		type: String
    genre:  		type: String
    feat:   		type: String
    tracks: 		type: [String]
    creationDate:       type: String
    lastModification:   type: String
    cover:              type: Object

Album.search = (name, callback) ->
    Album.request 'all', (err, data) ->
        return callback err if err
        stop = false
        loop
            break if data.length == 0
            elem = data.pop()
            if elem.name == name
                return callback null, elem
        return callback null, null
