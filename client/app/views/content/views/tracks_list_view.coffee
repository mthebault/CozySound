# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_list_view.coffee                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:09:28 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 14:23:16 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ViewCollection = require '../../../../lib/view_collection'
TracksRowView = require './tracks_row_view'

###
# TracksView is the structure for put tracks in content view
###
module.exports = class TracksListView extends ViewCollection
    template: require '../templates/tracks_list'
    el: '#table-screen'

    itemview: TracksRowView
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




    #TODO: improve it, it's not very pretty
    manageSelectionEvent: (event) ->
        cid = @$(event.target).parents('tr').data 'cid'
        view = _.find @views, (view) -> view.model.cid is cid

        _manageListTracksSelection = (clickedView) =>
            keys = _.keys @views
            startIndex = keys.indexOf @_lastTrackSelected.model.cid
            endIndex = keys.indexOf clickedView.model.cid
            loop
                if startIndex < endIndex then startIndex++ else startIndex--
                @selection.push @views[keys[startIndex]].model
                break if startIndex == endIndex


        if event.shiftKey && @_lastTrackSelected != null
            _manageListTracksSelection view
        else
            @selection.emptySelection()
            @selection.push view.model
        @_lastTrackSelected = view
        @triggerMenuOption()
