# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_row_view.coffee                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:13:31 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 01:10:08 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../../lib/base_view'

###
# Each TrackView represent a track in a collection
###
module.exports = class TrackRowView extends BaseView
    template: require '../templates/track_row'

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

        clicks = 0
        @$el.click (event) =>
            clicks++
            if clicks == 1
                if event.shiftKey
                    clicks = 0
                    return @collection.selectListTracks @
                @collection.selectTrack @
                setTimeout =>
                    if clicks > 1
                        window.app.player.onTrackDbClick @model, @collection
                    clicks = 0
                , 300


    doubleClick: (event) ->
        console.log 'event double: ', event

    refresh: ->
        @render()

    ########################## Manage Select stat ###############################
    setAsSelected: ->
        @$el.addClass 'success'

    setAsNoSelected: ->
        @$el.removeClass 'success'

    changeSelectStat: ->
        if @isTrackSelected()
            @setTrackAsNoSelected()
        else
            @setTrackAsSelected()
        return @_selectedStatus

    setAsSelected: ->
        @$el.addClass 'success'

    setAsNoSelected: ->
        @$el.removeClass 'success'


    ##################### END - Manage Select Stat - END #########################
