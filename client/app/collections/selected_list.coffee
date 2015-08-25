# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    selected_list.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/23 19:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/25 23:08:25 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'

###
# SelectedList is a collection of Track model selected by the user. This Tracks
# are references to Tracks models contains in the Base collection. So all action
# on tracks must be handle by this list which update the Base Collection and the
# view.It's the same collection for all content screen (playlist/all tracks/etc...)
# which is refresh.
###
module.exports = class SelectedTracksList extends Backbone.Collection
    model: Track
    url: 'tracks'

    # Keep the last track selected to have a starting point with shift. track is
    # a model
    _lastTrackSelected: null

    initialize: ->
        super
        # Create a shortcute for each track view can access to the selected
        # tracks list to trigger an event when they are selected
        window.selectedTracksList = @

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

    # Trigger an event when a some track is selected to pop the action track
    # menu. A other event is trigger to remove it
    add: (models, options) ->
        if @length == 0
            @trigger 'selectionTracksState', true
        super models, options

    remove: (models, options) ->
        super models, options
        if @length == 0
            @trigger 'selectionTracksState', false
    #################### END - Manage Select Stat - END #########################



    ############################ Edition tracks #################################
    updateTracks: ->
        console.log 'plop'
        $.ajax
            url: 'tracks'
            type: 'PUT'
            data: {data: @models}
            error: (xhr) ->
                console.error xhr
            success: (data) =>
                console.log data


    ###################### END - Edition tracks - END ###########################
