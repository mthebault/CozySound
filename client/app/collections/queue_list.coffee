# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    queue_list.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/13 15:53:34 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 19:12:22 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'

module.exports = class QueueList extends Backbone.Collection
    model: Track

    @name = null

    initialize: ->
        @selection = window.selection
        window.queue = @

    addSelection: ->
        loop
            break if @selection.length == 0
            @add @selection.shift()

    emptyQueue: ->
        loop
            break if @length == 0
            @pop()


    populate: (index, collectionName, collection) ->
        @name = collectionName
        @emptyQueue()
        loop
            break if index > collection.length
            @push collection.at(index)
            index++


    jumpInQueue: (track) ->
        @name = 'queue'
        loop
            break if @length == 0 || @at(0) == track
            @shift()
