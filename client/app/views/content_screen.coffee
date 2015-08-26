# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    content_screen.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 09:53:27 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/26 18:20:11 by ppeltier         ###   ########.fr        #
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
        @menu = window.app.leftMenu

        # SelectedTracksList is a collection of all tracks selected by the user,
        # all acions on tracks must be handle by it
        @selectedTracksList = new SelectedTracksList
        @selectedTracksList.baseCollection = @baseCollection

        # An array of all view currently prompt
        @currentView = new Array

        # Listen if a the selection collection in/out of state empty, pop/remove
        # the action menu
        @listenTo @selectedTracksList, 'selectionTracksState', @updateSelectionTracksState

        # Listen the creation of a new playlist
        @listenTo @menu, 'playlist-create', @createNewPlaylist


    removeCurrentView: ->
        loop
            break if @currentView.length == 0
            view = @currentView.pop()
            view.remove()

    ############################ ALL TRACKS #####################################
    # Render the context menu, create a view collection of the selectioned
    # collection and render it
    renderAllTracks: ->
        $('#content-screen').append @skeletonTrack
        # Initialize the contextMenu
        @_contextMenu = new ContextMenu
            selectedTracksList: @selectedTracksList
        # Listen if the user want edit the selectioned tracks
        @listenTo @_contextMenu, 'lauchTracksEdition', @lauchTracksEdition
        @_contextMenu.render()
        @currentView.push @_contextMenu


        # Initialize the tracks displayed
        @_collectionView = new TracksView
            collection: @baseCollection
        @_collectionView.render()
        @currentView.push @_collectionView


    ###################### END - ALL TRACKS - END ###############################


    ############################ TRACKS EDITION #################################
    # Remove current content and lauch edition
    lauchTracksEdition: ->
        @_contextMenu.manageActionTrackMenu false
        @removeCurrentView()
        @renderTracksEdition()

    renderTracksEdition: ->
        $('#content-screen').append @skeletonEdition
        # Initialize the Edition view
        @editionView = new EditionView
        # Listen the end of the edition
        @listenTo @editionView, 'edition-end', @finishEdition
        @editionView.render()
        @currentView.push @editionView

    finishEdition: ->
        @removeCurrentView()
        @renderAllTracks()
    ###################### END - TRACKS EDITION - END ###########################


    ################################ EVENTS #####################################
    createNewPlaylist: ->
        @removeCurrentView()


    updateSelectionTracksState: (isUsed) ->
        @_contextMenu.manageActionTrackMenu isUsed
    ########################## END - EVENTS - END ###############################

