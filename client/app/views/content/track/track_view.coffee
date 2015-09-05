# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track_view.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/20 18:08:58 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/05 19:21:30 by ppeltier         ###   ########.fr        #
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

    getRenderData: ->
        return { model: @model?.toJSON(), album: @model?.album?.toJSON()}

    afterRender: ->
        @$el.data 'cid', @model.cid
        if @model.isUploading()
            @$el.addClass 'warning'
        else if @model.isUploaded()
            @$el.removeClass 'warning'
        else if @model.isErrored()
            @$el.addClass 'danger'
        else if @model.isConflict()
            @$el.addClass 'info'

    refresh: ->
        @render()

    ########################## Manage Select stat ###############################
    setAsSelected: ->
        @$el.addClass 'success'

    setAsNoSelected: ->
        @$el.removeClass 'success'

    onTrackClicked: (event) -> # Check if shift or control have been pressed
        isShiftPressed = event.shiftKey or false
        window.selectedTracksList.onTrackClicked @model, isShiftPressed

    changeSelectStat: ->
        if @model.isSelected()
            @$el.addClass 'success'
        else
            @$el.removeClass 'success'
    ##################### END - Manage Select Stat - END #########################
