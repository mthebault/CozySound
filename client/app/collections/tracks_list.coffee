# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_list.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 18:42:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 05:36:11 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'

module.exports = class TracksList extends Backbone.Collection
    model: Track


    # Returns an existing model if a track with a similar id or a similar
    # tack is already in the queue.
    isTrackStored: (model) ->

        # first check by id
        existingTrack = @get model.get('id')

        # TODO: make the comparisons

        return existingTrack or null
