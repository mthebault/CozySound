# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_view.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 19:58:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/25 20:28:40 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'

module.exports = class EditionView extends BaseView
    template: require './templates/edition'

    @MERGED_ATTRIBUTES: ['title', 'artist', 'album', 'year', 'genre']

    initialize: ->
        @collection = window.selectedTracksList


    mergeMetaData: ->
        EditionView.MERGED_ATTRIBUTES.forEach (attribute) =>
            lastAttribute = undefined
            @collection.models.forEach (trackAttr) ->
                if lastAttribute != undefined and trackAttr.get attribute !== lastAttribute
                    console.log attribute, ' is differente'
                    break;
            console.log ''
