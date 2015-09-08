# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_view.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 17:13:40 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 22:49:39 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Menu = require './tracks_menu/tracks_menu_view'
TracksTableView = require './table_tracks/tracks_view'

module.exports = class AllTracksView
    skeleton: require './templates/all_tracks_skel'


    constructor: (options) ->
        _.extend @, Backbone.Events

        @selectedTracksList = options.selectedTracksList
        @baseCollection = options.baseCollection
        @frame = $('#content-screen')

        @frame.append @skeleton()

        @menu = new Menu
            selection : @selectedTracksList

        @tracks = new TracksTableView
            collection: @baseCollection
            selection: @selectedTracksList

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
        @selectedTracksList.emptySelection()
        @menu.manageOptionsMenu 'empty'

