# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    left_menu.coffee                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:40 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/18 15:50:38 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'

# Context_menu represent the menu on the top of the app. His goal is to work
# with tracks_screen. It must display the dynamiques option when the user select
# one or several song in the tracks screen.
module.exports = class LeftMenu extends BaseView

    template: require('./templates/left_menu')
    tagName: 'div'
    className: 'left-menu'

