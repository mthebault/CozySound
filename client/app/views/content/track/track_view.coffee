# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track_view.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/20 18:08:58 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/02 21:30:20 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'

###
# Each TrackView represent a track in a collection
###
module.exports = class TrackView extends BaseView
    template: require './templates/track'

    className: 'track-row'
    tagName: 'tr'


    afterRender: ->
        console.log 'model: ', @model
        @$el.data 'cid', @model.cid
        if @model.isUploading()
            @$el.addClass 'warning'
        else
            @$el.removeClass 'warning'

    refresh: ->
        #console.log @model.uploadStatus
        #console.log @model
        @render()

    ########################## Manage Select stat ###############################
    onTrackClicked: (event) -> # Check if shift or control have been pressed
        isShiftPressed = event.shiftKey or false
        window.selectedTracksList.onTrackClicked @model, isShiftPressed

    changeSelectStat: ->
        if @model.isSelected()
            @$el.addClass 'success'
        else
            @$el.removeClass 'success'

    ##################### END - Manage Select Stat - END #########################
