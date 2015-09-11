# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_row_list_view.coffee                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/11 14:50:58 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/11 14:59:43 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


BaseView = require '../../../../../lib/base_view'

module.exports = class TracksMenuRowView extends BaseView
    template: require '../../templates/tracks_menu/tracks_menu_row'

    className: 'tracks-menu-playlist-row'
    tagName: 'li'

    initialize: ->
        @$el.click => @model.addToPlaylist()
        @listenTo @model, 'change:name', @render
