# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    selected_list.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/23 19:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 11:52:36 by ppeltier         ###   ########.fr        #
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

    # Take a count of the number of track in update processing
    processingUpdate: 0

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

    updateTracks: (newAttrs) ->
        console.log newAttrs
        errorUpdating = 0
        successUpdating = 0
        loop
            track = @pop()
            track.setAsNoSelected()
            loop
                setOfAttr = newAttrs.pop()
                if track.get(setOfAttr[0]) != setOfAttr[1]
                    track.set setOfAttr[0], setOfAttr[1]
                    @processingUpdate++
                    console.log 'send: ', track
                    track.sync 'update', track,
                        error: (data) ->
                            @processingUpdate--
                            errorUpdating++
                        success: (data) ->
                            @processingUpdate--
                            successUpdating++
                break if newAttrs.length == 0
            break if @length == 0



    ###################### END - Edition tracks - END ###########################
