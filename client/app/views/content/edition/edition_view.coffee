# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_view.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 19:58:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/06 20:54:28 by ppeltier         ###   ########.fr        #
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
        album: {}

    events: ->
        'click #edit-cancel': -> @trigger 'edition-end'
        'click #edit-submit': 'submitEdition'

    initialize: ->
        @selection = window.selectedTracksList


    beforeRender: ->
        @processeAttr()
        console.log 'processed attr: ', @processedAttr


    getRenderData: ->
        return {
            album: @processedAttr.album
            track: @processedAttr.track
            allAlbum: @processedAttr.allAlbum}


    processeAttr: ->
        model = @selection.models[0]
        album = model.album
        EditionView.MERGED_ATTRIBUTES.forEach (attr) =>
            modelAttr = model.get attr
            albumAttr = album.get attr
            @processedAttr.track[attr] = if modelAttr then modelAttr else ''
            @processedAttr.album[attr] = if albumAttr then albumAttr else ''



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

    submitEdition: ->
        @saveEditionChanges()
        @trigger 'edition-end'
