# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_screen.coffee                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:14:16 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 17:14:58 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PlaylistView = require './views/playlist_view'

module.exports = class PlaylistScreen extends Backbone.View
    skeleton: require './skeletons/playlist_skel'

    #template: require './templates/playlist'
    el: '#playlist-header'


    constructor: ->
        _.extend @, Backbone.Events

        @frame = $('#content-screen')

        @frame.html @skeleton()

        @view = new PlaylistView
