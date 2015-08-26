# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_view.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 19:58:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 12:29:36 by ppeltier         ###   ########.fr        #
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

    processedAttr: {}

    events: ->
        'click #edit-cancel': 'cancelEdition'
        'click #edit-submit': 'submitEdition'

    initialize: ->
        @collection = window.selectedTracksList


    render: ->
        @mergeMetaData()
        @cleanProcessedAttr()
        @$el.append(@template {attr: @processedAttr})

    mergeMetaData: ->
        EditionView.MERGED_ATTRIBUTES.forEach (attribute) =>
            lastAttribute = undefined
            isSimilar = true
            @collection.models.forEach (track) ->
                if lastAttribute != undefined and track.get(attribute) != lastAttribute
                    isSimilar = false
                if lastAttribute == undefined
                    lastAttribute = track.get attribute
            if lastAttribute != undefined && isSimilar == true
                @processedAttr[attribute] = lastAttribute

    cleanProcessedAttr: ->
        EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
            if @processedAttr[attr] == undefined
                @processedAttr[attr] = ''

    saveEditionChanges: ->
        newInputAttr = new Array
        EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
            attrValue = @processedAttr[attr]
            inputValue = @$("#edit-#{attr}").val()
            if inputValue != '' and attrValue != inputValue
                newInputAttr.push [attr, inputValue]
        @collection.updateTracks newInputAttr

    computeChangeAttr: (attribute, inputValue) ->
        @collection.models.forEach (track) ->
            track.set attribute, inputValue



    cancelEdition: ->
        @freeSelectedTracksList()
        @trigger 'edition-end'

    submitEdition: ->
        @saveEditionChanges()
        @trigger 'edition-end'

    freeSelectedTracksList: ->
        loop
            track = @collection.pop()
            track.setAsNoSelected()
            break if @collection.length == 0
