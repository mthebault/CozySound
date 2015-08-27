# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_view.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 22:26:12 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/27 02:00:22 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'

module.exports = class PlaylistView extends BaseView
    template: require './templates/playlist'
    el: '#playlist-screen'

    # model is a Playlist object
    initialize: (model) ->
        @model = model
        console.log @model

