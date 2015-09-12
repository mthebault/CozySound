# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    application.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 23:12:34 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

AppView = require './views/app_view'
TracksList = require './collections/tracks_list'
UploadQueue = require './collections/upload_queue'
AlbumList = require './collections/album_list'
PlaylistList = require './collections/playlists_list'

###
# Represent the app, all global variables must be set in it and not in window
###
module.exports =

    initialize: ->

        # Create a shortcut
        window.app = @

        @albumCollection = new AlbumList

        # BaseCollection is the main collection where all the tracks are stored, all
        # the others list must have only a reference to a track of this list
        @baseCollection = new TracksList

        @playlistsCollection = new PlaylistList
        @playlistsCollection.fetch()


        @soundManager = soundManager

        # Print the main structure
        mainView = new AppView
        mainView.render()



        # Routing management
        #Router = require 'router'
        #@router = new Router()
        @baseCollection.fetch()


        @soundManager.setup
            # disable or enable debug output
            debugMode: false
            debugFlash: false
            useFlashBlock: false
            # always prefer flash even for MP3/MP4 when HTML5 audio is available
            preferFlash: true
            # setup the display update rate while reading songs (in ms)
            flashPollingInterval: 500
            html5PollingInterval: 500
            # path to directory containing SM2 SWF
            url: 'swf/'
            # optional: enable MPEG-4/AAC support (requires flash 9)
            flashVersion: 9
            onready: ->
                mainView.playerScreen.onReady()
            ontimeout: ->
                mainView.playerScreen.onTimeout()

        Backbone.history.start()

        # uploadQueue is the list of track waiting to be uploaded. The tracks in
        # uploadQueue are also added to the mainTrackList to be printed.
        @uploadQueue = new UploadQueue @baseCollection

        # Makes this object immuable.
        Object.freeze this if typeof Object.freeze is 'function'
