# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 20:21:09 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 20:58:58 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

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
    lastModifivation:   Date
    creationDate:       Date
    clearance:          cozydb.NoSchema
    binary:             Object
    uploading:          Boolean
    checksum:           String


Track.getByArtistAndTitle = (param, callback) ->
    Track.request "artistAndTitle", param, callback

