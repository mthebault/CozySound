# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_view.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 19:58:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/25 20:47:03 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'

module.exports = class EditionView extends BaseView
    template: require './templates/edition'

    @MERGED_ATTRIBUTES: ['title', 'artist', 'album', 'year', 'genre']

    processedAttr: {}

    initialize: ->
        @collection = window.selectedTracksList


    render: ->
        @mergeMetaData()
        super

    mergeMetaData: ->
        EditionView.MERGED_ATTRIBUTES.forEach (attribute) =>
            lastAttribute = undefined
            isSimilar = true
            @collection.models.forEach (trackAttr) ->
                console.log 'loop-> lastAttribute : ', lastAttribute, ' / attr: ', trackAttr.get attribute
                if lastAttribute != undefined and trackAttr.get(attribute) != lastAttribute
                    console.log attribute, ' is differente'
                    isSimilar = false
                if lastAttribute == undefined
                    lastAttribute = trackAttr.get attribute
            console.log 'lastAttribute : ', lastAttribute, ' / similar: ', isSimilar
            if lastAttribute != undefined && isSimilar == true
                console.log 'set : ', attribute
                @processedAttr[attribute] = lastAttribute
            console.log @processedAttr


            console.log ''
