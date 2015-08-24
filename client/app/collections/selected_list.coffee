# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    selected_list.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/23 19:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/24 17:08:20 by ppeltier         ###   ########.fr        #
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

    # Keep the last track selected to have a starting point with shift. track is
    # a model
    _lastTrackSelected: null

    initialize: (options) ->
        super
        @baseCollection = options.baseCollection


    onTrackClicked: (view, isShiftPressed = false) ->
        if isShiftPressed == false
            @manageTrackSelection view.model
        else
            @manageListTracksSelection view.model
        @_lastTrackSelected = view.model

    manageListTracksSelection: (lastView) ->
        startIndex = @baseCollection.indexOf @_lastTrackSelected
        endIndex = @baseCollection.indexOf lastView
        loop
            if startIndex < endIndex
                startIndex++
            else startIndex--
            @manageTrackSelection @baseCollection.at startIndex
            break if startIndex == endIndex



    # Check the select stat of the view and add/remove his to the collection
    manageTrackSelection: (model) ->
        if model.isSelected() == false
            if @addToSelection(model) == false
                return
        else
            if @removeToSelection(model) == false
                return
        @trigger 'toggle-select', cid: @cid

    addToSelection: (model) ->
        @add model
        if model.setAsSelected() == false
            @remove model
            return false
        return true

    removeToSelection: (model) ->
        @remove model
        if model.setAsNoSelected() == false
            @add model
            return false
        return true
