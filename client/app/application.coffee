# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    application.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/25 16:45:41 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

AppView = require './views/app_view'
TracksList = require './collections/tracks_list'
UploadQueue = require './collections/upload_queue'

module.exports =

    initialize: ->

        # Create a shortcut
        window.app = @

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
