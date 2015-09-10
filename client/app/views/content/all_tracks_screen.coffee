# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    all_tracks_screen.coffee                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:13:43 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/10 22:17:13 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

TracksMenuView = require './views/tracks_menu_view'
TracksListView = require './views/tracks_list_view'

module.exports = class AllTracksScreen
    skeleton: require './skeletons/all_tracks_skel'


    constructor: (options) ->
        _.extend @, Backbone.Events

        @selection = window.selection
        @baseCollection = options.baseCollection
        @frame = $('#content-screen')

        @frame.append @skeleton()

        @menu = new TracksMenuView
            selection : @selection

        @tracks = new TracksListView
            collection: @baseCollection
            selection: @selection

        # *** menu-editMenu-prompte ***
        # from: onTrackClicker - collections/selected_list.coffee
        # argument: bool (state)
        @listenTo @tracks, 'selection-menu-options', @menu.manageOptionsMenu

        @listenTo @menu, 'track-management-remove', @baseCollection.removeTracksFromSelection


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

