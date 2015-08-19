# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    upload_queue.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 23:50:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 06:45:53 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'

module.exports = class UploadQueue
    model: Track

    # number of tracks actually loaded
    loaded: 0

    # TODO: Catch event "badFileType" and prompt an error
    # TODO: Catch event "upload-complete"

    constructor: (@baseCollection) ->

        # Create a collection for elements to be processed by the queue. This
        # information is not based on the base collection for performance
        # reasons (it doesn't have to be updated each time a big folder is
        # loaded.)
        @uploadCollection = new Backbone.Collection()

        # Backbone.Events is a mixin, not a "class" you can extend.
        _.extend @, Backbone.Events

        @asyncQueue = async.queue @uploadWorker, 5
        @asyncQueue.drain = @completeUpload.bind @


    # Retrieve all data needed in the metadata and the ID3 metadata
    # What is ID3 ?? -> https://en.wikipedia.org/wiki/ID3
    # TODO: Improve the ID3 reader
    # TODO: parse title -> take the ID3 title usualy much better
    # TODO: retrieve album picture -> will be complicate because that need an
    # inter app protocole with file and/or picture app
    # TODO: There is lot's of other data to retrieve, may be interesting to look
    # up
    retrieveDataBlob: (blob) ->
        model = new Track
            title: blob.name
            lastModified: blob.lastModifiedDate
            size: blob.size
            type: blob.type

        file: blob
        total: blob.size

        reader = new FileReader()
        reader.onload = (event) ->
            ID3.loadTags blob.name, ( ->
                tags = ID3.getAllTags blob.name
                model.set
                    title: if tags.title? then tags.title
                    artist: if tags.artist? then tags.artist else ''
                    album: if tags.album? then tags.album else ''
                    track: if tags.track? then tags.track else ''
                    year: if tags.year? then tags.year else ''
                    genre: if tags.genre? then tags.genre else ''
                    time: if tags.TLEN?.data? then tags.TLEN.data else ''
            ),
            tags: ["title","artist","album","track","year","genre","TLEN"]
            dataReader: FileAPIReader blob
        reader.readAsArrayBuffer blob

        return model

    addBlobs: (blobs) ->
        #@reset if @completed // not implemented

        i = 0
        # Non blocking loop, handling one file every 2ms so the UI don't get
        # stuck
        do nonBlockingLoop = =>
            return unless blob = blobs[i++]


            # Check if the client have send a good format
            # TODO: Later check if it's a picture to get the covert
            if not blob.type.match /audio\/(mp3|mpeg)/ #list of supported filetype
                @trigger 'badFileType'
            else
                model = @retrieveDataBlob blob

                # Check if a same track is already stored in the base collection
                if (existingModel = @isTrackStored(model)?)
                    # Check if the track is in upload process or if it's already
                    # successfully added
                    if not existingModel.inUploadCycle() or existingModel.isUploaded()
                        # update data
                        existingModel.set
                            size: blob.size
                            lastModification: blob.lastModifiedDate

                        existingModel.file = blob
                        existingModel.loaded = 0
                        existingModel.total = blob.size

                        model = existingModel

                        model.markAsConflict()
                        @trigger 'conflict', model
                    else
                        # Prevent the track from being added to the queue.
                        model = null
                if model?
                    @add model

            setTimeout nonBlockingLoop, 2


    # Add a to the operations in progress, change his status and
    # push it in the queue
    add: (model) ->
        window.pendingOperations.upload++ # set in initialize.coffee

        # don't override conflict status
        model.markAsUploading() unless model.isConflict()

        # Add to the base collection to print it
        @baseCollection.add model

        # Add to the upload collection so it can be precessed
        @uploadCollection.add model

        # Push it at the end of the queue
        @asyncQueue.push model


    # Perform the actual persistence by saving the model and changing
    # uploadStatus based on response. If there is an unexpected error,
    # it tries again 3 times before failing.
    _processSave: (model, done) ->
        if not model.isErrored() and not model.isConflict()
            model.save null,
                success: (model) =>
                    model.file = null
                    # Make sure progress is uniform, we force it a 100%
                    model.loaded = model.total
                    model.markAsUploaded()
                    done null
                error: (_, err) =>
                    model.file = null
                    body = try JSON.parse(err.responseText)
                    catch e then msg: null
                    if err.status is 400 and body.code is 'ESTORAGE'
                        model.markAsErrored body
                    else if err.status is 0 and err.statusText is 'error'
                        # abort by user, don't try again

                    # Retry if an unexpected error occurs
                    else
                        model.tries = 1 + (model.tries or 0)
                        if model.tries > 3
                            defaultMessage = "modal error track upload"
                            model.error = t err.msg or defaultMessage
                            errorKey = err.msg or defaultMessage
                            error = t errorKey
                            model.markAsErrored error
                        else
                            # let's try again
                            @asyncQueue.push model
                #done()
        else
            done()


    # Process each element in the queue
       uploadWorker: (model, next) =>
        # Skip if there is an error.
        if model.error
            setTimeout next, 10

        # If there is a conflict, the queue waits for the user to
        # make a decision.
        else if model.isConflict()
            alert 'CONFLICT'
        # Otherwise, the upload starts directly.
        else
            @_processSave model, next


    # Reset variables and trigger completion events.
    completeUpload: =>
        window.pendingOperations.upload = 0
        @completed = true
        @trigger 'upload-complete'


    # Returns an existing model if a track with a similar id or a similar
    # location (path + name) is already in the queue.
    isTrackStored: (model) ->
        return @baseCollection.isTrackStored model
