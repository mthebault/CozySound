# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_view.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/20 17:41:32 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/06 18:03:40 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ViewCollection = require '../../../lib/view_collection'
TrackView = require './track_view'

###
# TracksView is the structure for put tracks in content view
###
module.exports = class TracksView extends ViewCollection
    template: require './templates/tracks'
    el: '#display-screen'

    itemview: TrackView
    collectionEl: '#table-items-content'

    selectedTrack: null

    tracksSelected: []

    events:
        # Event delegation
        'click tr.track-row': 'manageSelectionEvent'

    # Keep the last track selected to have a starting point with shift. track is
    # a model
    _lastTrackSelected: null


    initialize: (options) ->
        super options

        # Event delegation: Take the model send as argument in event and run his
        # methode named as the second argument
        @listenTo @collection, 'change', _.partial(@viewProxy, 'refresh')

    afterRender: ->
        super



    # Manage event delegation. Events are listen to on the collection level,
    # then the callback are called on the view that originally triggered them.
    #
    # * `methodName` is the method that will be called on the View.
    # * `object` can be a File model or a DOMElement within FileView.$el
    viewProxy: (methodName, object) ->

        # Get view's cid. Views are indexed by cid. Object can be a File model
        # or a DOMElement within FileView.$el.
        if object.cid?
            cid = object.cid
        else
            cid = @$(object.target).parents('tr').data 'cid'

            unless cid?
                cid = @$(object.currentTarget).data 'cid'

        # Get the view.
        view = _.find @views, (view) -> view.model.cid is cid

        # In case of deletion, view may not exist anymore.
        if view?
            # Call `methodName` on the related view.
            args = [].splice.call arguments, 1
            view[methodName].apply view, args


    unselectAllTracks: ->
        loop
            break if @tracksSelected.length == 0
            view = @tracksSelected.pop()
            view.setTrackAsNoSelected()
        window.app.contentScreen.selectedTracksList.emptySelection()


    manageSelectionEvent: (event) ->
        event.stopPropagation()
        event.preventDefault()
        console.log 'event: ', event
        listTracksModified = []
        cid = @$(event.target).parents('tr').data 'cid'
        view = _.find @views, (view) -> view.model.cid is cid


        _manageListTracksSelection = (lastView) =>
            startIndex = @views.indexOf @_lastTrackSelected
            endIndex = @views.indexOf lastView
            loop
                if startIndex < endIndex then startIndex++ else startIndex--
                _manageTrackSelection @views[startIndex]
                break if startIndex == endIndex

        _manageTrackSelection = (view) =>
            view.changeSelectStat()
            if view.isTrackSelected()
                @tracksSelected.push view
            listTracksModified.push view

        if event.shiftKey && @_lastTrackSelected != null
            _manageListTracksSelection view
        else
            @unselectAllTracks()
            _manageTrackSelection view
        @_lastTrackSelected = view
        window.app.contentScreen.selectedTracksList.manageSelectionModification listTracksModified

