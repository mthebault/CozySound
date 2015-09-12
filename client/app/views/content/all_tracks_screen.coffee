# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    all_tracks_screen.coffee                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:13:43 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 16:20:33 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

TracksMenuView = require './views/tracks_menu/tracks_menu_view'
TracksListView = require './views/tracks_list_view'

module.exports = class AllTracksScreen
    skeleton: require './skeletons/all_tracks_skel'


    constructor: (options) ->
        _.extend @, Backbone.Events

        @selection = window.selection
        @queue = window.app.queueList
        @baseCollection = options.baseCollection
        @frame = $('#content-screen')

        @frame.append @skeleton()

        @menu = new TracksMenuView
            selection : @selection
        @listenTo @menu, 'track-management-remove', @baseCollection.removeTracksFromSelection
        @listenTo @menu, 'track-add-queue', @sendSelectionToQueue


        @tracks = new TracksListView
            collection: @baseCollection
            selection: @selection
        @listenTo @tracks, 'selection-menu-options', @menu.manageOptionsMenu

    sendSelectionToQueue: ->
        @queue.addSelection()
        @menu.manageOptionsMenu 'empty'



    render: ->
        @selection.emptySelection()
        @menu.render()
        @tracks.render()


    attach: ->
        @selection.emptySelection()
        @menu.manageOptionsMenu 'empty'
        @frame.append @menu.el
        @frame.append @tracks.el

    detach: ->
        @menu.$el.detach()
        @tracks.$el.detach()

