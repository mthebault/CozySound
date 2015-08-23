# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    selected_list.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/23 19:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/23 20:08:26 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'

###
# SelectedList is a collection of track selected by the user. All action on
# tracks must be managed by it
###
module.exports = class SelectedTracksList extends Backbone.Collection
    model: Track
    url: 'tracks'

    # Keep the last track selected to have a starting point with shift
    lastTrackSelected: null

    initialize: (options) ->
        super
        @baseCollectionView = options.baseCollectionView

    onTrackClicked: (view, isShiftPressed = false) ->
        console.log 'selected'
        console.log 'isShiftPressed: ', isShiftPressed
        console.log view
        console.log "collection: ", @baseCollectionView
