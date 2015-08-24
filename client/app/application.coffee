# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    application.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/24 19:26:06 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

AppView = require './views/app_view'
TracksList = require './collections/tracks_list'
UploadQueue = require './collections/upload_queue'
TracksView = require './views/content/track/tracks_view'
SelectedTracksList = require './collections/selected_list'

module.exports =

    initialize: ->

        # Create a shortcut
        window.app = @

        # BaseCollection is the main collection where all the tracks are stored, all
        # the others list must have only a reference to a track of this list
        @baseCollection = new TracksList

        # SelectedTracksList is a collection of all tracks selected by the user,
        # all acions on tracks must be handle by it
        @selectedTracksList = new SelectedTracksList
        @selectedTracksList.baseCollection =  @baseCollection

        # Print the main structure
        mainView = new AppView
            selectedTracksList: @selectedTracksList
        mainView.render()

        # BaseCollection View is a collection of all views in baseCollection,
        # may be just temporary
        @baseCollectionView = new TracksView
            collection: @baseCollection

        # uploadQueue is the list of track waiting to be uploaded. The tracks in
        # uploadQueue are also added to the mainTrackList to be printed.
        @uploadQueue = new UploadQueue @baseCollection



        # Used in inter-app communication
        #SocketListener = require '../lib/socket_listener'

        # Routing management
        Router = require 'router'
        @router = new Router()
        Backbone.history.start()

        # Makes this object immuable.
        Object.freeze this if typeof Object.freeze is 'function'
