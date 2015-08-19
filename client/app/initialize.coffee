# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    initialize.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:35 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 03:32:20 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

app = require 'application'
TracksList = require './collections/tracks_list'
UploadQueue = require './collections/upload_queue'


# The function called from index.html
$ ->
    require 'lib/app_helpers'

    ######## Initialize Polyglot ############
    # Based on cozy-contact
    @locale = window.locale
    delete window.locale

    @polyglot = new Polyglot()

    try
        locales = require "locales/" + @locale
    catch err
        locales = require 'locales/en'

    # we give polyglot the data
    @polyglot.extend @locales

    # handy shortcut
    window.t = @polyglot.t.bind @polyglot
    ######## END - Initialize Polyglot - END ############


    # Keep count of the operations in progress
    window.pendingOperations =
        upload: 0

    # mainTracksList is the main collection where all the tracks are stored, all
    # the others list must have only a reference to a track of this list
    window.mainTracksList = new TracksList
    # uploadQueue is the list of track waiting to be uploaded. The tracks in
    # uploadQueue are also added to the mainTrackList to be printed.
    window.uploadQueue = new UploadQueue window.mainTracksList

    app.initialize()
