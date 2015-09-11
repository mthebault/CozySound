# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_menu_view.coffee                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/11 15:12:32 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/11 15:15:19 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../../lib/base_view'

module.exports = class PlaylistMenuView extends BaseView

    template: require '../templates/playlist_menu'
    el: '#playlist-menu'


    events:
        'click #playlist-menu-remove': -> @trigger 'remove-current-playlist'
