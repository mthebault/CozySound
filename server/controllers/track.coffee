# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 06:50:00 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 23:26:08 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

multiparty = require 'multiparty'
crypto = require 'crypto'
feed = require '../lib/feed'
log = require('printit')
    prefix: 'track'
Track = require './../models/track'
moment = require 'moment'
async = require 'async'


# Fetch params.nbTracks tracks from params.start
fetchRange = (req, res, next) ->
    if not req.params.start or not req.params.nbTracks
        err = new Error "Bad arguments, no range given"
        err.status = 400
        return next err
    Track.fetchByRange {skip: req.params.start, limit: req.params.nbTracks}, (err, data) ->
        if err
            res.send
                error: true
                code: 'EFRETREIVE'
                , 500
        else
            res.status(200).send(data)


fetchListTracks = (req, res, next) ->
    data = []


    processSearch = (id, next) =>
        Track.find id, (err, track) =>
            return next err if err
            data.push track
            next()

    queue = async.queue processSearch, 10

    queue.drain = ->
        res.status(200).send(data)


    queue.push req.query.listId



all = (req, res, next) ->
    Track.request 'all', (err, data) ->
        if err
            res.send
                error: true
                code: 'ERETREIVE'
                msg: 'modal err retrieve'
            , 500
        else
            res.status(200).send(data)


update = (req, res, next) ->
    data = req.body
    Track.find data.id, (err, trackFind) ->
        return next err if err
        data.lastModified = moment(Date.now())
        #TODO: set correctly the date
        trackFind.updateAttributes data, (err) ->
            if err
                res.send
                    error: true
                    code: 'EUPDATE'
                    data: trackFind
                    msg: 'model err update'
            else
                res.status(200).send(data)



# Prior to track creation it ensures that all parameters are correct then it
# builds the track document from given information and uploaded track metadata.
# Once done, it performs all database operation and index the track name.
timeout = null


# check if an error is storage related
isStorageError = (err) ->
    return err.toString().indexOf('enough storage') isnt -1

create = (req, res, next) ->
    clearTimeout(timeout) if timeout?

    # Represent all fields retrieved
    fields = {}

    # Parse given form to extract image blobs
    form = new multiparty.Form()

    form.on 'part', (part) ->
        # We recieve the data in a stream so it send the data by "parts", each
        # part represent a data or the blob. This next lines check if the part
        # is note the blob (link with meta "filename"). If that put the data in
        # the fields object
        if not part.filename?
            fields[part.name] = ''
            part.on 'data', (buffer) ->
                fields[part.name] = buffer.toString()
            return

        # TODO: make a better parse on the fields

        # We assume that only one track is sent.
        # we do not write a subfunction because it seems to load the whole
        # stream in memory.
        title = fields.title
        upload = true
        canceled = false
        uploadStream = null

        # we have no title for this track, give up
        if not title or title is ""
            err = new Error "Invalid arguments: no title given"
            err.status = 400
            return next err

        # while this upload is processing
        # we send usage.application to prevent auto-stop
        keepAlive = ->
            if upload
                feed.publish 'usage.application', 'tracks'
                setTimeout keepAlive, 60*1000

        # if anything happens after the track is created
        # we need to destroy it
        rollback = (track, err) ->
            canceled = true
            track.destroy (delerr) ->
                # nothing more we can do with delerr
                log.error delerr if delerr
                if isStorageError err
                    res.send
                        error: true
                        code: 'ESTORAGE'
                        msg: "modal error size"
                    , 400
                else
                    next err


        attachBinary = (track) ->
            part.title = track.title
            checksum = crypto.createHash 'sha1'
            checksum.setEncoding 'hex'
            part.pause()
            part.pipe checksum
            metadata = name: "track"
            uploadStream = track.attachBinary part, metadata, (err) ->
                # rollback if there was an error
                return rollback track, err if err #and not canceled

                # TODO move everythin below in the model.
                checksum.end()
                checksum = checksum.read()

                # set the track checksum

                if not canceled

                    data =
                        checksum: checksum

                    track.updateAttributes data, (err) ->
                        # we ignore checksum storing errors
                        log.debug err if err

                        # index the track in cozy-indexer for fast search
                        track.index ["title", "artist"], (err) ->
                            # we ignore indexing errors
                            log.debug err if err

                            # Retrieve binary metadata
                            Track.find track.id, (err, track) =>
                                log.debug err if err
                                res.status(200).send(track)


        # TODO: Check if track already exist



        ATTRIBUTES = ["title","artist","album","track","year","genre","TLEN", 'time', 'docType', 'size']

        # Retrieve all metaData
        data =
            title: title
            trackNb: fields.trackNb
            album: fields.album
            artist: fields.artist
            year: fields.year
            genre: fields.genre
            time: fields.time
            docType: fields.dockType
            size: part.byteCount
            plays: 0

        ATTRIBUTES.forEach (attr) ->
            elem = data[attr]
            if not elem? or elem == "undefined"
                delete data[attr]


        # Save track metadata
        Track.create data, (err, newTrack) ->
            return next err if err

            # Ask for the data system to not run autostop
            # while the upload is running.
            keepAlive()

            # If user stops the upload, the track is deleted.
            err = new Error 'Request canceled by user'
            res.on 'close', ->
                log.info 'Upload request closed by user'
                uploadStream.abort()

            # Attach track in database.
            attachBinary newTrack


    form.on 'error', (err) ->
        log.error err

    form.parse req

module.exports =
    fetchRange: fetchRange
    all: all
    update: update
    create: create
    fetchListTracks: fetchListTracks
