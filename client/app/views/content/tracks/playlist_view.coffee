# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 16:13:30 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 18:35:29 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


module.exports = class PlaylistView extends Backbone.View
    template: require './templates/playlist'
    el: '#playlist-header'


    render: ->
        console.log 'model: ', @model
        super
