# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    selected_list.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/23 19:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/24 18:37:13 by ppeltier         ###   ########.fr        #
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

    ########################## Manage Select stat ###############################
    onTrackClicked: (model, isShiftPressed = false) ->
        if isShiftPressed == true && @_lastTrackSelected != null
            @_manageListTracksSelection model
        else
            @_manageTrackSelection model
        @_lastTrackSelected = model

    _manageListTracksSelection: (lastModel) ->
        startIndex = @baseCollection.indexOf @_lastTrackSelected
        endIndex = @baseCollection.indexOf lastModel
        loop
            if startIndex < endIndex
                startIndex++
            else startIndex--
            @_manageTrackSelection @baseCollection.at startIndex
            break if startIndex == endIndex



    # Check the select stat of the view and add/remove his to the collection
    _manageTrackSelection: (model) ->
        if model.isSelected() == false
            @add model
            model.setAsSelected()
        else
            @remove model
            model.setAsNoSelected()

    ##################### END - Manage Select Stat - END #########################
