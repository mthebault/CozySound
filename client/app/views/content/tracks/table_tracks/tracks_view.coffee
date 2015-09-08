# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_view.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/20 17:41:32 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 22:33:51 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ViewCollection = require '../../../../lib/view_collection'
TrackView = require './track_view'

###
# TracksView is the structure for put tracks in content view
###
module.exports = class TracksView extends ViewCollection
    template: require './templates/tracks'
    el: '#table-screen'

    itemview: TrackView
    collectionEl: '#table-items-content'

    events:
        # Event delegation
        'click tr.track-row': 'manageSelectionEvent'


    # Keep the last track selected to have a starting point with shift. track is
    # a model
    _lastTrackSelected: null


    initialize: (options) ->
        @selection = options.selection
        @collection = options.collection
        super

        @listenTo @selection, 'remove', _.partial(@viewProxy, 'setAsNoSelected')

        @listenTo @selection, 'add', _.partial(@viewProxy, 'setAsSelected')

        # Event delegation: Take the model send as argument in event and run his
        # methode named as the second argument
        @listenTo @collection, 'change', _.partial(@viewProxy, 'refresh')


    triggerMenuOption: ->
        switch @selection.length
            when 0 then @trigger 'selection-menu-options', 'empty'
            when 1 then @trigger 'selection-menu-options', 'unique'
            else
                @trigger 'selection-menu-options', 'several'

    manageSelectionEvent: (event) ->
        cid = @$(event.target).parents('tr').data 'cid'
        view = _.find @views, (view) -> view.model.cid is cid

        _manageListTracksSelection = (lastView) =>
            startIndex = @views.indexOf @_lastTrackSelected
            endIndex = @views.indexOf lastView
            loop
                if startIndex < endIndex then startIndex++ else startIndex--
                @selection.push @views[startIndex].model
                break if startIndex == endIndex


        if event.shiftKey && @_lastTrackSelected != null
            _manageListTracksSelection view
        else
            @selection.emptySelection()
            @selection.push view.model
        @_lastTrackSelected = view
        @triggerMenuOption()
