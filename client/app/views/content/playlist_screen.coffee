# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_screen.coffee                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:14:16 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 23:22:21 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

module.exports = class PlaylistView extends Backbone.View
    template: require './templates/playlist'
    el: '#playlist-header'


    render: ->
        console.log 'model: ', @model
        super
