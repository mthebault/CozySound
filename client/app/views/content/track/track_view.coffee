# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track_view.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/20 18:08:58 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/23 20:04:19 by ppeltier         ###   ########.fr        #
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

    # Define if the track is selected or not, is manages by the selected
    # collection
    isSelected: false

    refresh: ->
        console.log @model.uploadStatus
        console.log @model
        @render()

    onTrackClicked: (event) ->
        # Check if shift or control have been pressed
        isShiftPressed = event.shiftKey or false
        window.app.selectedTracksList.onTrackClicked @, isShiftPressed


    afterRender: ->
        @$el.data 'cid', @model.cid

        if @model.isUploading()
            @$el.addClass 'warning'
        else
            @$el.removeClass 'warning'

