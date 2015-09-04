# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track_view.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/20 18:08:58 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/04 14:32:05 by ppeltier         ###   ########.fr        #
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
        console.log 'model data : ', @model
        console.log 'album data : ', @model.album
        console.log 'model data view: ', @model?.toJSON()
        console.log 'album data view: ', @model?.album?.toJSON()
        return { model: @model?.toJSON(), album: @model?.album?.toJSON()}

    afterRender: ->
        @$el.data 'cid', @model.cid
        if @model.isUploading()
            @$el.addClass 'warning'
        else
            @$el.removeClass 'warning'

    refresh: ->
        @render()

    ########################## Manage Select stat ###############################
    setAsSelected: ->
        @$el.addClass 'success'

    setAsNoSelected: ->
        @$el.removeClass 'success'
    ##################### END - Manage Select Stat - END #########################
