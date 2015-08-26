# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    content_screen.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 09:53:27 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/25 22:14:29 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ContextMenu = require './context_menu'
SelectedTracksList = require '../collections/selected_list'
TracksView = require '../views/content/track/tracks_view'
EditionView = require '../views/content/edition/edition_view'

module.exports = class ContentScreen

    skeletonTrack: require './content/track_skel'
    skeletonEdition: require './content/edition_skel'

    constructor: ->
        _.extend @, Backbone.Events

        @baseCollection = window.app.baseCollection

        # SelectedTracksList is a collection of all tracks selected by the user,
        # all acions on tracks must be handle by it
        @selectedTracksList = new SelectedTracksList
        @selectedTracksList.baseCollection = @baseCollection


        # Listen if a the selection collection in/out of state empty, pop/remove
        # the action menu
        @listenTo @selectedTracksList, 'selectionTracksState', @updateSelectionTracksState

        # Set baseCollection, so all tracks as the first collection printed
        @_collection = @baseCollection


    ############################ ALL TRACKS #####################################
    # Render the context menu, create a view collection of the selectioned
    # collection and render it
    renderAllTracks: ->
        $('#content-screen').append @skeletonTrack
        # Initialize the contextMenu
        @_contextMenu = new ContextMenu
            selectedTracksList: @selectedTracksList

        # Initialize the tracks displayed
        @_collectionView = new TracksView
            collection: @baseCollection
        @_collectionView.render()

        # Listen if the user want edit the selectioned tracks
        @listenTo @_contextMenu, 'lauchTracksEdition', @lauchTracksEdition
        @_contextMenu.render()


    removeAllTracks: ->
        @_contextMenu.remove()
        @_collectionView.remove()
    ###################### END - ALL TRACKS - END ###############################


    updateSelectionTracksState: (isUsed) ->
        @_contextMenu.manageActionTrackMenu isUsed

    ############################ TRACKS EDITION #################################
    # Remove current content and lauch edition
    lauchTracksEdition: ->
        @_contextMenu.manageActionTrackMenu false
        @removeAllTracks()
        @renderTracksEdition()

    renderTracksEdition: ->
        $('#content-screen').append @skeletonEdition
        # Initialize the Edition view
        @editionView = new EditionView
        # Listen the end of the edition
        @listenTo @editionView, 'edition-end', @finishEdition
        @editionView.render()

    finishEdition: ->
        @removeTracksEdition()
        @renderAllTracks()

    removeTracksEdition: ->
        @editionView.remove()

    ###################### END - TRACKS EDITION - END ###########################

