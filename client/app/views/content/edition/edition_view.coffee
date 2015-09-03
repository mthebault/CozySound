# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_view.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 19:58:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/03 12:28:12 by ppeltier         ###   ########.fr        #
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
        @selection = window.selectedTracksList


    render: ->
        @$el.append(@template {attr: @selection})

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
