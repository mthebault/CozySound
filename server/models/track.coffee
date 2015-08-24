# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 20:21:09 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/24 13:16:00 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

cozydb = require 'cozydb'

module.exports = Track = cozydb.getModel 'Track',
    title:      	String
    artist:      	String
    album:      	String
    trackNb:    	String
    year:       	String
    genre:      	String
    time:       	Number #not sur that is the right type
    size:       	Number
    plays:      	Number
    docType:            String
    lastModification:   String
    creationDate:       String
    clearance:          cozydb.NoSchema
    binary:             Object
    uploading:          Boolean
    checksum:           String


Track.fetchByRange = (params, callback) ->
    console.log params
    Track.request "byRange", params, callback
