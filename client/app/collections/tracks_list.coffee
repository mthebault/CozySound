# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_list.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 18:42:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/02 21:24:04 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'

###
# Represents a collection of tracks
# It acts as a cache when instanciate as the baseCollection
# The base collection holds ALL tracks of the application
###
module.exports = class TracksList extends Backbone.Collection
    model: Track
    url: 'track'

    # Number of tracks downloaded to each call of fetch
    sizeFrameDownload: 5

    # Set the number of tracks downloaded, each call of fetch will increment it
    # by sizeFrameDownload
    cursorFrameDownload: 0

    # Returns an existing model if a track with a similar id or a similar
    # tack is already in the queue.
    isTrackStored: (model) ->

        # first check by id
        existingTrack = @get model.get('id')

        # TODO: make the comparisons

        return existingTrack or null

    # Change to fetch data by range, it ask the server to retrieve the number of
    # tracks set in sizeFrameDownload from cursorFrameDownload and in case of
    # success add the number of tracks retrieved to cursorFramDownload
    fetch: ->
        $.ajax
            url: "track/#{@cursorFrameDownload}/#{@sizeFrameDownload}"
            type: 'GET'
            error: (xhr) ->
                console.error xhr
            success: (data) =>
                @cursorFrameDownload += data.length
                @add data
