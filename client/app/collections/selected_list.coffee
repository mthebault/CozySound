# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    selected_list.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/05 19:01:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/07 16:14:39 by ppeltier         ###   ########.fr        #
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


    # Take a count of the number of track in update processing
    processingUpdate: 0
    # Take a count of the success and error updating
    errorUpdating: 0
    successUpdating: 0

    editionMenuPrompted: false

    initialize: ->
        super
        # Create a shortcute for each track view can access to the selected
        # tracks list to trigger an event when they are selected
        window.selectedTracksList = @

    ########################## Manage Select stat ###############################
    manageSelectionModification: (listView) ->
        listView.forEach (view) =>
            if view.isTrackSelected() then @push view.model else @remove view.model
        if @length == 1 and @editionMenuPrompted == false
            @trigger 'selection-editMenu-prompte', true
            @editionMenuPrompted = true
        else if @length != 1 and @editionMenuPrompted == true
            @trigger 'selection-editMenu-prompte', false
            @editionMenuPrompted = false

    emptySelection: (listView) ->
        loop
            break if @length == 0
            @pop()
        @editionMenuPrompted = false


    #################### END - Manage Select Stat - END #########################



    ############################ Edition tracks #################################

    updateTracks: (newAttrs) ->
        errorUpdating = 0
        successUpdating = 0
        setOfAttr = null
        loop
            track = @pop()
            track.setAsNoSelected()
            i = 0
            loop
                setOfAttr = newAttrs[i]
                if track.get(setOfAttr[0]) != setOfAttr[1]
                    memory = track.get(setOfAttr[0])
                    track.set setOfAttr[0], setOfAttr[1]
                i++
                break if i == newAttrs.length
            @processingUpdate++
            track.sync 'update', track,
                error: (res) =>
                    @setUpdateError()
                    @set res.data
                success: (data) =>
                    @setUpdateSuccess()
            break if @length == 0


    setUpdateError: ->
        @processingUpdate--
        @errorUpdating++
        @checkProcessingUpdateQueue()

    setUpdateSuccess: ->
        @processingUpdate--
        @successUpdating++
        @checkProcessingUpdateQueue()

    checkProcessingUpdateQueue: ->
        if @processingUpdate == 0
            console.log 'EDITION: ', @successUpdating, ' successe and ', @errorUpdating, ' error'
    ###################### END - Edition tracks - END ###########################
