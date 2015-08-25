# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    content_screen.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 09:53:27 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/25 13:32:06 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ContextMenu = require './context_menu'
SelectedTracksList = require '../collections/selected_list'
TracksView = require '../views/content/track/tracks_view'

module.exports = class ContentScreen

    _collection: null
    _collectionView: null


    constructor: ->
        _.extend @, Backbone.Events

        @baseCollection = window.app.baseCollection

        # SelectedTracksList is a collection of all tracks selected by the user,
        # all acions on tracks must be handle by it
        @selectedTracksList = new SelectedTracksList
        @selectedTracksList.baseCollection = @baseCollection

        # Initialize the contextMenu
        @contextMenu = new ContextMenu
            selectedTracksList: @selectedTracksList

        # Set baseCollection, so all tracks as the first collection printed
        @_collection = @baseCollection

        # Listen if a the selection collection in/out of state empty, pop/remove
        # the action menu
        @listenTo @selectedTracksList, 'selectionTracksState', @contextMenu.manageActionTrackMenu

    render: ->
        @contextMenu.render()
        # Create a new CollectionView with the new collection
        @_collectionView = new TracksView
            collection: @_collection
        @_collectionView.render()
