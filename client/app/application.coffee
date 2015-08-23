# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    application.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/23 20:21:17 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

AppView = require './views/app_view'
TracksList = require './collections/tracks_list'
UploadQueue = require './collections/upload_queue'
SelectedTracksList = require './collections/selected_list'

module.exports =

    initialize: ->

        # Create a shortcut
        window.app = @

        # BaseCollection is the main collection where all the tracks are stored, all
        # the others list must have only a reference to a track of this list
        @baseCollection = new TracksList

        ## BaseCollection View is a collection of all views in baseCollection,
        ## may be just temporary
        #@baseCollectionView = null

        # SelectedTracksList is a collection of all tracks selected by the user,
        # all acion on tracks must be handle by it
        @selectedTracksList = new SelectedTracksList
            baseCollectionView: @baseCollectionView

        # uploadQueue is the list of track waiting to be uploaded. The tracks in
        # uploadQueue are also added to the mainTrackList to be printed.
        @uploadQueue = new UploadQueue @baseCollection

        # Print the main structure
        mainView = new AppView()
        mainView.render()


        # Used in inter-app communication
        #SocketListener = require '../lib/socket_listener'

        # Routing management
        Router = require 'router'
        @router = new Router()
        Backbone.history.start()

        # Makes this object immuable.
        Object.freeze this if typeof Object.freeze is 'function'
