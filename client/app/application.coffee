# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    application.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/05 19:08:54 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

AppView = require './views/app_view'
TracksList = require './collections/tracks_list'
UploadQueue = require './collections/upload_queue'
AlbumList = require './collections/album_list'

###
# Represent the app, all global variables must be set in it and not in window
###
module.exports =

    initialize: ->

        # Create a shortcut
        window.app = @

        @albumCollection = new AlbumList
        #@albumCollection.fetch()

        # BaseCollection is the main collection where all the tracks are stored, all
        # the others list must have only a reference to a track of this list
        @baseCollection = new TracksList

        # Print the main structure
        mainView = new AppView
        mainView.render()

        # Routing management
        Router = require 'router'
        @router = new Router()
        Backbone.history.start()

        # uploadQueue is the list of track waiting to be uploaded. The tracks in
        # uploadQueue are also added to the mainTrackList to be printed.
        @uploadQueue = new UploadQueue @baseCollection

        # Makes this object immuable.
        Object.freeze this if typeof Object.freeze is 'function'
