# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    left_menu.coffee                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:40 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 15:54:39 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'

###
# LefMenu represent the main panel option. His goal is trigger the changing
# of content in the tracks screen
###
module.exports = class LeftMenu extends BaseView

    template: require './templates/left_menu'
    tagName: 'div'
    className: 'left-menu'
    el: '#left-menu'

    events:
        'click #menu-playlist-new': 'createNewPlaylist'

    createNewPlaylist: ->
        console.log 'plop'


