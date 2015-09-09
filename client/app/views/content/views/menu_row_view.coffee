# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    menu_row_view.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/09 12:36:43 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 16:56:10 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../../lib/base_view'

module.exports = class MenuRowView extends BaseView
    template: require '../templates/menu_row'

    className: 'tracks-menu-playlist-row'
    tagName: 'li'

    initialize: ->
        @$el.click => @model.addToPlaylist()
