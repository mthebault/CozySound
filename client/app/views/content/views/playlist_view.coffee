# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_view.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/09 17:16:36 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 17:47:01 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../../lib/base_view'

module.exports = class PlaylistView extends BaseView
    template: require '../templates/playlist'

    el: '#playlist-header'

    initialize: (options) ->
        @playlist = options.playlist

    getRenderData: ->
        return {playlist: @playlist.toJSON()}
