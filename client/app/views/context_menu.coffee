# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    context_menu.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/18 15:52:11 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'

# Context_menu represent the menu on the top of the app. His goal is to work
# with tracks_screen. It must display the dynamiques option when the user select
# one or several song in the tracks screen.
module.exports = class ContextMenu extends BaseView

    template: require('./templates/context_menu')
    tagName: 'div'
    className: 'context-menu'

