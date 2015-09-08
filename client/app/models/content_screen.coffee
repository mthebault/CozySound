# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    content_screen.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/25 09:53:27 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 22:49:36 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

AllTracksView = require '../views/content/tracks/all_tracks_view'
PlaylistView = require '../views/content/tracks/playlist_view'
EditionView = require '../views/content/edition_screen'
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

    currentView: null

    playlistPrinted: null

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
        @loadedViews = new Array

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
    renderSkeleton: (skeleton, data) ->
        if data?
            dataParsed = {data: data?.toJSON()}
        $('#content-screen').append(skeleton(dataParsed))


    removeCurrentView: ->
        switch @currentView
            when 'allTracks' then @removeAllTracks()
            when 'trackEdition' then @removeTrackEdition()
            when 'playlist' then @removePlaylist()
    ###################### END - GENERIQUE - END ################################


    ############################ ALL TRACKS #####################################
    renderAllTracks: ->
        @removeCurrentView()
        @currentView = 'allTracks'
        @renderTracks()

    removeAllTracks: ->
        @currentView = null
        @removeTracks()

    renderTracks: ->
        if @loadedViews['allTracks']?
            @loadedViews['allTracks'].attach()
            return

        # Initialize the tracks displayed
        allTracks = new AllTracksView
            selectedTracksList: @selectedTracksList
            baseCollection: @baseCollection


        @loadedViews['allTracks'] = allTracks

        allTracks.render()

        # Initialize the tracksMenu
        # *** menu-trackEdition-lauch ***
        # from: events - views/content/tracks_menu/tracks_menu.coffee
        # argument:
        @listenTo allTracks.menu, 'menu-trackEdition-lauch', @renderTrackEdition


    removeTracks: ->
        @loadedViews['allTracks'].detach()
    ###################### END - ALL TRACKS - END ###############################



    ############################## PLAYLIST #####################################

    renderPlaylist: (playlist) ->
        @removeCurrentView()
        @currentView = 'playlist'
        playlist.render()
        @playlistPrinted = playlist


    removePlaylist: ->
        @playlistPrinted.remove()
        @playlistPrinted = null
    ######################## END - PLAYLIST END - ###############################



    ############################ TRACKS EDITION #################################
    # Remove current content and lauch edition
    renderTrackEdition: ->
        @removeCurrentView()
        @currentView =  'trackEdition'
        @renderEdition()


    renderEdition: ->
        if @loadedViews['trackEdition']?
            @loadedViews['trackEdition'].attach()
            return

        # Initialize the Edition view
        editionView = new EditionView

        @loadedViews['trackEdition'] = editionView

        editionView.render()

        # Listen the end of the edition
        @listenTo editionView.view, 'edition-end', @renderAllTracks


    removeTrackEdition: ->
        @selectedTracksList.emptySelection()
        @loadedViews['trackEdition']?.detach()
        @loadedViews['allTracks']?.clearSelection()
    ###################### END - TRACKS EDITION - END ###########################
