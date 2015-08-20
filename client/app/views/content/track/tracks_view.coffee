# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_view.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/20 17:41:32 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/20 22:38:43 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ViewCollection = require '../../../lib/view_collection'
TrackView = require './track_view'

###
# TracksView is a collection of TrackView and it's contain in the tracks screen
###
module.exports = class TracksView extends ViewCollection
    itemview: TrackView
    template: require './templates/tracks'
    collectionEl: '#content'


    initialize: (options) ->
        # Link with the base collection and the upload queue
        @collection = options.baseCollection
        @uploadQueue = options.uploadQueue


        # Event delegation.
        #@listenTo @collection, 'change', _.partial(@viewProxy, 'refresh')
