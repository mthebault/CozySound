# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_view.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 23:04:17 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 14:48:13 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'

module.exports = class PlaylistView extends BaseView
    template: require './templates/playlist'

    className: 'playlist-row'
    tagName: 'li'

    initialize: ->
        @$el.click => window.app.menuScreen.trigger 'content-print-playlist', @model

