# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_view.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 19:58:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/03 16:55:47 by ppeltier         ###   ########.fr        #
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

    @MERGED_ATTRIBUTES: ['title', 'artist', 'album', 'year', 'genre']

    # Take a count of the number of track in update processing to send a
    # notification when it's finish
    processingUpdate: 0

    processedAttr:
        track: {}
        album: []

    events: ->
        'click #edit-cancel': 'cancelEdition'
        'click #edit-submit': 'submitEdition'

    initialize: ->
        @selection = window.selectedTracksList


    prepareSelection: ->
        if @selection.length == 1
            @renderSingleTrackEdition()
        else
            console.log 'print list track'

    renderSingleTrackEdition: ->
        @mergeTrackData()

    render: ->
        @prepareSelection()
        @mergeAlbumData()
        @cleanProcessedAttr()
        @$el.append(@template {data: @processedAttr})

    mergeAlbumData: ->
        @selection.models.forEach (track) =>
            album = track.get 'album'
            dataAlbum = track.get('album')
            @processedAttr.album.push dataAlbum
            console.log 'attr album: ', @processedAttr.album




    mergeTrackData: ->
        EditionView.MERGED_ATTRIBUTES.forEach (attribute) =>
            lastAttribute = undefined
            isSimilar = true
            @selection.models.forEach (track) ->
                if lastAttribute != undefined and track.get(attribute) != lastAttribute
                    isSimilar = false
                if lastAttribute == undefined
                    lastAttribute = track.get attribute
            if lastAttribute != undefined && isSimilar == true
                @processedAttr.track[attribute] = lastAttribute

    cleanProcessedAttr: ->
        EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
            if @processedAttr.track[attr] == undefined
                @processedAttr.track[attr] = ''
            @selection.models.forEach (track) ->


    saveEditionChanges: ->
        newInputAttr = new Array
        EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
            attrValue = @processedAttr[attr]
            inputValue = @$("#edit-#{attr}").val()
            if inputValue != '' and attrValue != inputValue
                newInputAttr.push [attr, inputValue]
        @selection.updateTracks newInputAttr

    computeChangeAttr: (attribute, inputValue) ->
        @selection.models.forEach (track) ->
            track.set attribute, inputValue



    cancelEdition: ->
        @freeSelectedTracksList()
        @trigger 'edition-end'

    submitEdition: ->
        @saveEditionChanges()
        @trigger 'edition-end'

    freeSelectedTracksList: ->
        loop
            track = @selection.pop()
            track.setAsNoSelected()
            break if @selection.length == 0
