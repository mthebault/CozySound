# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    queue_screen.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/12 13:20:13 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 14:39:01 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

TracksListView = require './views/tracks_list_view'

module.exports = class QueueScreen
    skeleton: require './skeletons/queue_skel'


    constructor: ->
        _.extend @, Backbone.Events

        @selection = window.selection
        @queue = window.app.queueList

        @frame = $('#content-screen')

        @frame.html @skeleton()

        @tracks = new TracksListView
            collection: @queue
            selection: @selection


    render: ->
        @selection.emptySelection()
        @tracks.render()

    attach: ->
        @selection.emptySelection()
        @frame.append @tracks.el

    detach: ->
        @tracks.$el.detach()
