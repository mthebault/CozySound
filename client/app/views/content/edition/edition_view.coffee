# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_view.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 19:58:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/03 20:59:41 by ppeltier         ###   ########.fr        #
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

    # Take a count of the number of track in update processing to send a
    # notification when it's finish
    processingUpdate: 0

    processedAttr:
        track: {}
        album: []
        allAlbum: null

    events: ->
        'click #edit-cancel': 'cancelEdition'
        'click #edit-submit': 'submitEdition'

    initialize: ->
        @selection = window.selectedTracksList


    beforeRender: ->
        @mergeArrayOfData @selection.models, @processedAttr.track
        console.log 'final track data: ', @processedAttr.track
        @mergeAlbumData()
        @cleanProcessedAttr()


    getRenderData: ->
        console.log 'album: ', @processedAttr.album
        console.log 'track: ', @processedAttr.track
        return {
            albums: @processedAttr.album
            track: @processedAttr.track
            allAlbum: @processedAttr.allAlbum}


    mergeAlbumData: ->
        @selection.models.forEach (track) =>
            album = track.get 'album'
            merged =  @processedAttr.album.find (elem, index, array) ->
                if elem.name == album.name
                    return true
                return false
            if not merged
                @processedAttr.album.push album.toJSON()
        if @processedAttr.album.length > 1
            @mergeArrayOfData @processedAttr.album, @processedAttr.allAlbum




    mergeArrayOfData: (array, dest) ->
        console.log 'array: ', array
        EditionView.MERGED_ATTRIBUTES.forEach (attribute) =>
            console.log 'ATTRIBUTE: ', attribute
            mergedAttr = undefined
            #array.find (elem, index, array) ->

            i = 0
            loop
                break if i >= array.length
                elem = array[i]
                console.log 'elem: ', elem
                console.log 'match: ', elem.get(attribute), ' / ', mergedAttr
                elemAttr = elem.get attribute
                if elemAttr?
                    if mergedAttr != undefined and elemAttr != mergedAttr
                        mergedAttr = ''
                        break
                    if mergedAttr == undefined
                        mergedAttr = elemAttr
                i++
            dest[attribute] = mergedAttr

    cleanProcessedAttr: ->
        EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
            if @processedAttr.track[attr] == undefined
                @processedAttr.track[attr] = ''
            @processedAttr.album.forEach (album) ->
                if album[attr] == undefined
                    album[attr] = ''



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
