# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    queue_screen.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/13 15:57:35 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 18:38:10 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

TracksListView = require './views/tracks_list_view'

module.exports = class QueueScreen
    skeleton: require './skeletons/queue_skel'



    constructor: (options) ->
        _.extend @, Backbone.Events

        @queue = window.app.queue
        @queuePrev = window.app.queuePrev
        @selection = window.selection
        @player = window.app.player

        @frame = $('#content-screen')

        @frame.append @skeleton()

        @tracks = new TracksListView
            collection: @queue
            selection: @selection

        console.log 'queue Prev: ', @queuePrev.models
        @queuePrevViews = new TracksListView
            collection: @queuePrev
            selection: @selection
            el: '#table-screen-prev'


    render: ->
        @selection.emptySelection()
        @queuePrevViews.render()
        @tracks.render()

    attach: ->
        @selection.emptySelection()
        @frame.append @tracks.el
        @frame.append @queuePrevViews.el


    detach: ->
        @tracks.$el.detach()
        @queuePrevViews.$el.detach()
