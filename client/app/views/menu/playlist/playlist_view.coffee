# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_view.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/26 23:04:17 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/07 22:46:31 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'

module.exports = class PlaylistView extends BaseView
    template: require './templates/playlist'
    tagName: 'li'
