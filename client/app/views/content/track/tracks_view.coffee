# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_view.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/20 17:41:32 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/23 17:23:37 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ViewCollection = require '../../../lib/view_collection'
TrackView = require './track_view'

###
# TracksView is the structure for put tracks in content view
###
module.exports = class TracksView extends ViewCollection
    template: require './templates/tracks'
    el: '#content'

    itemview: TrackView
    collectionEl: '#table-items-content'
