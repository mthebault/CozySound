# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    album.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/02 11:17:57 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 23:06:00 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


module.exports = class Album extends Backbone.Model
    url: 'album'



    set: (attr, options) ->
        tracks = @get 'tracks'
        tracks?.forEach (trackId) ->
            track = window.app.baseCollection.get trackId
            track?.set attr
        super attr, options


