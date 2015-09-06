# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    content_screen.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 09:53:27 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/06 18:03:27 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ContextMenu = require '../views/content/context_menu/context_menu'
TracksView = require '../views/content/track/tracks_view'
EditionView = require '../views/content/edition/edition_view'
SelectedTracksList = require '../collections/selected_list'

###
# ContenScreen is the main screen where all tracks are printed. This is a
# generique class to print any collection of tracks with an optional skeleton.
# The collection must contain only Track models set int /models/track.coffee.
# All track must be a reference to a track in @baseCollection which is a sort of
# cache
#
# # Rendering
# All content must have a method named "render<content name>" which in order:
# - Call removeCurrentView()
# - Call renderSkeleton(skeleton, data) (optional)
# - set @currentcollection
# - set custom things
# - Call renderTracks()
#
# # Skeleton
# You can render a Skeleton with the function renderSkeleton(skeleton, data).
# The argument skeleton must be a jade file. The argument data is all data
# accessible in the jade file. You can reach theme by the methode "data". The
# template must contain a div with the id "display-screen" where the track
# screen will be print
#
# # Contents
# - All tracks: print @baseCollection
# - Playlist: trigger by the event "content-print-playlist" with the collection
# in argument
#
###
module.exports = class ContentScreen

    skeletonPlaylist: require '../views/content/track/templates/playlist_skel'
    skeletonEdition: require '../views/content/edition/templates/edition_skel'

    constructor: ->
        _.extend @, Backbone.Events

        window.app.contentScreen = @
        @baseCollection = window.app.baseCollection
        @menu = window.app.menuScreen

        # SelectedTracksList is a collection of all tracks selected by the user,
        # all actions on tracks must be handle by it
        @selectedTracksList = new SelectedTracksList
        @selectedTracksList.baseCollection = @baseCollection

        # An array of all view currently prompt
        @currentView = new Array

    ################################ EVENTS #####################################
        # *** content-print-playlist ***
        # from: createNewPlaylist - models/menu_screen.coffee
        # argument: Playlist object
        @listenTo @menu, 'content-print-playlist', @renderPlaylist

        # *** content-print-allTracks ***
        # from: events - models/menu_screen.coffee
        # argument:
        @listenTo @menu, 'content-print-allTracks', @renderAllTracks
    ########################## END - EVENTS - END ###############################




    ############################ GENERIQUE ######################################

    renderContextMenu: ->
        # Initialize the contextMenu
        @_contextMenu = new ContextMenu

        # *** menu-trackEdition-lauch ***
        # from: events - views/content/context_menu/context_menu.coffee
        # argument:
        @listenTo @_contextMenu, 'menu-trackEdition-lauch', @renderTracksEdition

        # *** menu-editMenu-prompte ***
        # from: onTrackClicker - collections/selected_list.coffee
        # argument: bool (state)
        @listenTo @selectedTracksList, 'selection-editMenu-prompte', @updateSelectionTracksState

        @_contextMenu.render()
        @currentView.push @_contextMenu


    renderTracks: ->
        # Initialize the tracks displayed
        @_collectionView = new TracksView
            collection: @currentCollection

        @_collectionView.render()
        @currentView.push @_collectionView

    renderSkeleton: (skeleton, data) ->
        dataParsed = {data: data?.toJSON()}
        $('#content-screen').append(skeleton(dataParsed))


    removeCurrentView: ->
        loop
            break if @currentView.length == 0
            view = @currentView.pop()
            view.remove()

    updateSelectionTracksState: (isUsed) ->
        @_contextMenu.manageActionTrackMenu isUsed
    ###################### END - GENERIQUE - END ################################




    ############################ ALL TRACKS #####################################
    renderAllTracks: ->
        console.log 'plop'
        @removeCurrentView()
        @currentCollection = @baseCollection
        @renderContextMenu()
        @renderTracks()
    ###################### END - ALL TRACKS - END ###############################





    ############################## PLAYLIST #####################################
    renderPlaylist: (playlist) ->
        @removeCurrentView()
        @renderSkeleton @skeletonPlaylist, playlist
        @currentCollection = playlist.collection
        console.log @currentCollection
        @renderTracks()
    ######################## END - PLAYLIST END - ###############################





    ############################ TRACKS EDITION #################################
    # Remove current content and lauch edition
    renderTracksEdition: ->
        @removeCurrentView()
        @renderSkeleton @skeletonEdition
        # Initialize the Edition view
        @editionView = new EditionView
        # Listen the end of the edition
        @listenTo @editionView, 'edition-end', @finishEdition
        @editionView.render()
        @currentView.push @editionView
    ###################### END - TRACKS EDITION - END ###########################


