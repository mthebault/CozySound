# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    all_tracks_screen.coffee                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:13:43 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 11:09:26 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

TracksMenuView = require './views/tracks_menu_view'
TracksListView = require './views/tracks_list_view'

module.exports = class AllTracksView
    skeleton: require './skeletons/all_tracks_skel'


    constructor: (options) ->
        _.extend @, Backbone.Events

        @selection = options.selection
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


    render: ->
        @menu.render()
        @tracks.render()


    attach: ->
        @frame.append @menu.el
        @frame.append @tracks.el

    detach: ->
        @menu.$el.detach()
        @tracks.$el.detach()

    clearSelection: ->
        @selection.emptySelection()
        @menu.manageOptionsMenu 'empty'
