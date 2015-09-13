# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    content_manager.coffee                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:06:49 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 18:53:23 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

AllTracksScreen = require '../views/content/all_tracks_screen'
PlaylistScreen = require '../views/content/playlist_screen'
EditionScreen = require '../views/content/edition_screen'
QueueScreen = require '../views/content/queue_screen'

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
module.exports = class ContentManager

    currentView: null

    playlistPrinted: null

    constructor: ->
        _.extend @, Backbone.Events

        window.app.contentManager = @
        @baseCollection = window.app.baseCollection
        @menu = window.app.menuScreen

        @selection = window.selection

        # An array of all view currently prompt
        @loadedScreens = []

    ################################ EVENTS #####################################
        # *** content-print-playlist ***
        # from: createNewPlaylist - models/menu_screen.coffee
        # argument: Playlist object
        @listenTo @menu, 'content-print-playlist', @renderPlaylist

        # *** content-print-allTracks ***
        # from: events - models/menu_screen.coffee
        # argument:
        @listenTo @menu, 'content-print-allTracks', @renderAllTracks

        # *** content-print-queue ***
        # from: events - models/menu_screen.coffee
        # argument:
        @listenTo @menu, 'content-print-queue', @renderQueue
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
            when 'queue' then @removeQueue()
    ###################### END - GENERIQUE - END ################################


    ############################ ALL TRACKS #####################################
    renderAllTracks: ->
        @removeCurrentView()
        @currentView = 'allTracks'

        if @loadedScreens['allTracks']?
            @loadedScreens['allTracks'].attach()
            return

        # Initialize the tracks displayed
        allTracks = new AllTracksScreen
            baseCollection: @baseCollection


        @loadedScreens['allTracks'] = allTracks

        allTracks.render()

        # Initialize the tracksMenu
        # *** menu-trackEdition-lauch ***
        # from: events - views/content/tracks_menu/tracks_menu.coffee
        # argument:
        @listenTo allTracks.menu, 'menu-trackEdition-lauch', @renderTrackEdition



    removeAllTracks: ->
        @loadedScreens['allTracks'].detach()
        @currentView = null
    ###################### END - ALL TRACKS - END ###############################



    ############################## PLAYLIST #####################################

    renderPlaylist: (playlist) ->
        playlistId = playlist.id
        @removeCurrentView()
        @currentView = 'playlist'

        if @loadedScreens[playlistId]
            @loadedScreens[playlistId].attach()
            @playlistPrinted = @loadedScreens[playlistId]
            return

        view = new PlaylistScreen
            playlist: playlist

        @loadedScreens[playlistId] = view

        @listenTo view, 'playlist-end', @renderAllTracks

        view.render()
        @playlistPrinted = view


    removePlaylist: ->
        @playlistPrinted.detach()
        @playlistPrinted = null
        @currentView = null
    ######################## END - PLAYLIST END - ###############################



    ############################ TRACKS EDITION #################################
    # Remove current content and lauch edition
    renderTrackEdition: ->
        @removeCurrentView()
        @currentView =  'trackEdition'

        if @loadedScreens['trackEdition']?
            @loadedScreens['trackEdition'].attach()
            return

        # Initialize the Edition view
        editionScreen = new EditionScreen

        @loadedScreens['trackEdition'] = editionScreen

        editionScreen.render()

        # Listen the end of the edition
        @listenTo editionScreen.view, 'edition-end', @renderAllTracks


    removeTrackEdition: ->
        @loadedScreens['trackEdition']?.detach()
        @currentView = null
    ###################### END - TRACKS EDITION - END ###########################

    ################################ QUEUE ######################################
    renderQueue: ->
        @removeCurrentView()
        @currentView = 'queue'

        if @loadedScreens['queue']?
            @loadedScreens['queue'].attach()
            return

        view = new QueueScreen

        @loadedScreens['queue'] = view

        view.render()


    removeQueue: ->
        @loadedScreens['queue']?.detach()
        @currentView = null
    ########################## END - QUEUE - END ################################

    getPrintedCollection: ->
        switch @currentView
            when 'allTracks' then {collection: @baseCollection, name: 'AllTracks'}
            when 'playlist' then {collection: @playlistPrinted.playlist.collection, name: @playlistPrinted.playlist.name}
            when 'queue' then {name: 'queue'}
