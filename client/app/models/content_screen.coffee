# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    content_screen.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 09:53:27 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/27 02:01:31 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

SelectedTracksList = require '../collections/selected_list'
ContextMenu = require '../views/content/context_menu/context_menu'
TracksView = require '../views/content/track/tracks_view'
EditionView = require '../views/content/edition/edition_view'
PlaylistView = require '../views/content/playlist/playlist_view'

module.exports = class ContentScreen

    skeletonTrack: require '../views/content/track/templates/track_skel'
    skeletonEdition: require '../views/content/edition/templates/edition_skel'
    skeletonPlaylist: require '../views/content/playlist/templates/playlist_skel'

    constructor: ->
        _.extend @, Backbone.Events

        @baseCollection = window.app.baseCollection
        @menu = window.app.menuScreen

        # SelectedTracksList is a collection of all tracks selected by the user,
        # all acions on tracks must be handle by it
        @selectedTracksList = new SelectedTracksList
        @selectedTracksList.baseCollection = @baseCollection

        # An array of all view currently prompt
        @currentView = new Array

        # Listen if a the selection collection in/out of state empty, pop/remove
        # the action menu
        @listenTo @selectedTracksList, 'selectionTracksState', @updateSelectionTracksState

        # *** menu-cmd-playlist ***
        # from: createNewPlaylist - models/menu_screen.coffee
        # action: Remove current content and prompt the playlist in argument
        # argument: Playlist object
        @listenTo @menu, 'menu-cmd-playlist', @lauchPlaylist


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

    updateSelectionTracksState: (isUsed) ->
        @_contextMenu.manageActionTrackMenu isUsed
    ########################## END - EVENTS - END ###############################


    ############################## PLAYLIST #####################################
    lauchPlaylist: (playlist) ->
        @removeCurrentView()
        $('#content-screen').append @skeletonPlaylist
        @renderPlaylist playlist

    renderPlaylist: (playlist) ->
        @_playlistView = new PlaylistView playlist
        @_playlistView.render()
        @currentView.push @_playlistView
    ######################## END - PLAYLIST END - ###############################
