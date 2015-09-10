# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlists_row_view.coffee                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:20:14 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/10 11:20:49 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'

module.exports = class PlaylistRowView extends BaseView
    template: require './templates/playlist'

    className: 'playlist-row'
    tagName: 'li'

    initialize: ->
        @$el.click => window.app.menuScreen.trigger 'content-print-playlist', @model

        @listenTo @model, 'change:name', @render
