# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_view.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 19:58:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 19:57:21 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'

###
# Edition View is the view manager of the tracks edition screen. It handle the
# processing of the data's selectedTracksList tracks to merge it and in case of
###
module.exports = class EditionView extends BaseView
    template: require './templates/edition'

    el: '#edition-screen'

    @MERGED_ATTRIBUTES: ['title', 'artist', 'year', 'genre', 'name']

    processedAttr:
        track: {}
        album: {}

    events: ->
        'click #edit-cancel': -> @trigger 'edition-end'
        'click #edit-submit': 'submitEdition'


    initialize: ->
        @selection = window.selectedTracksList


    beforeRender: ->
        @processeAttr()

    getRenderData: ->
        return {
            album: @processedAttr.album
            track: @processedAttr.track}


    processeAttr: ->
        model = @selection.models[0]
        album = model.album
        EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
            modelAttr = model.get attr
            albumAttr = album.get attr
            @processedAttr.track[attr] = if modelAttr then modelAttr else ''
            @processedAttr.album[attr] = if albumAttr then albumAttr else ''

    saveTrackChanges: ->
        loop
            break if @selection.length == 0
            track = @selection.pop()
            newInputAttr = null
            EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
                inputValue = @$("#edit-track-#{attr}").val()
                if inputValue != '' and track.get(attr) != inputValue
                    if newInputAttr == null then newInputAttr = {}
                    newInputAttr[attr] = inputValue
            @saveAlbumChanges track

            if newInputAttr?
                track.save newInputAttr

    saveAlbumChanges: (track) ->
        newInputAttr = null
        album = track.album
        EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
            inputValue = @$("#edit-album-#{attr}").val()
            if inputValue != '' and album.get(attr) != inputValue
                if newInputAttr == null then newInputAttr = {}
                newInputAttr[attr] = inputValue

        if newInputAttr?
            album.save newInputAttr


    submitEdition: ->
        @saveTrackChanges()
        @trigger 'edition-end'
