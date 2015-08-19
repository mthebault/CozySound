# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 06:50:00 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 23:03:34 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

multiparty = require 'multiparty'
moment = require 'moment'
Track = require './../models/track'
log = require('printit')
    prefix: 'track'

# Prior to track creation it ensures that all parameters are correct and that no
# track already exists with the same name. Then it builds the track document from
# given information and uploaded track metadata. Once done, it performs all
# database operation and index the track name. Finally, it tags the track if the
# parent folder is tagged.
folderParent = {}
timeout = null

# Helpers functions of upload process

# check if an error is storage related
isStorageError = (err) ->
    return err.toString().indexOf('enough storage') isnt -1

# After 1 minute of inactivity, update parents
resetTimeout = ->
    clearTimeout(timeout) if timeout?
    timeout = setTimeout updateParents, 60 * 1000

# Save in RAM lastModification date for parents
# Update folder parent once all files are uploaded
#updateParents = ->
    #errors = {}
    #for name in Object.keys(folderParent)
        #folder = folderParent[name]
        #folder.save (err) ->
            #errors[folder.name] = err if err?
    #folderParent = {}


#confirmCanUpload = (data, req, next) ->

    ## owner can upload.
    #return next null if not req.public
    #element = new File data
    #sharing.checkClearance element, req, 'w', (authorized, rule) ->
        #if authorized
            ##if rule?
                ##req.guestEmail = rule.email
                ##req.guestId = rule.contactid
            #next()
        #else
            #err = new Error 'You cannot access this resource'
            #err.status = 404
            #err.template =
                #name: '404'
                #params:
                    #localization: require '../lib/localization_manager'
                    #isPublic: true
            #next err

module.exports.create = (req, res, next) ->
    clearTimeout(timeout) if timeout?

    # Represent all fields retrieved
    fields = {}

    # Parse given form to extract image blobs
    form = new multiparty.Form()

    console.log 'BEGIN CREATE'
    form.on 'part', (part) ->
        # We recieve the data in a stream so it send the data by "parts", each
        # part represent a data or the blob. This next lines check if the part
        # is note the blob (link with meta "filename"). If that put the data in
        # the fields object
        if not part.filename?
            console.log 'PART META: ', part.name
            fields[part.name] = ''
            part.on 'data', (buffer) ->
                fields[part.name] = buffer.toString()
            return

        console.log 'PART: ', part.filename
        # TODO: parse the fields like year or track

        # We assume that only one track is sent.
        # we do not write a subfunction because it seems to load the whole
        # stream in memory.
        title = fields.title
        lastModification = moment(new Date(fields.lastModifiedDate)).toISOString()
        # Not implemented yet
        #overwrite = fields.overwrite
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
        # and we defer parents lastModification update
        keepAlive = ->
            if upload
                feed.publish 'usage.application', 'tracks'
                setTimeout keepAlive, 60*1000
                resetTimeout()

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
            # request-json requires a path field to be set
            # before uploading
            part.title = track.title
            checksum = crypto.createHash 'sha1'
            checksum.setEncoding 'hex'
            part.pause()
            part.pipe checksum
            metadata = name: "track"
            uploadStream = track.attachBinary part, metadata, (err) ->
                upload = false
                # rollback if there was an error
                return rollback track, err if err #and not canceled

                # TODO move everythin below in the model.
                checksum.end()
                checksum = checksum.read()

                # set the track checksum

                if not canceled

                    data =
                        checksum: checksum
                        uploading: false

                    track.updateAttributes data, (err) ->
                        # we ignore checksum storing errors
                        log.debug err if err

                        # index the track in cozy-indexer for fast search
                        track.index ["title"], (err) ->
                            # we ignore indexing errors
                            log.debug err if err

                            # Retrieve binary metadata
                            Track.find track.id, (err, track) ->
                                log.debug err if err
                                res.send track, 200
                                #end

        now = moment().toISOString()

        # Check that the track doesn't exist yet.
        # The comparison is make for the moment by the name/artist
        # TODO: improve it
        Track.getByArtistAndTitle keys: ['title', 'artist'], (err, sameTracks) ->
            console.log "end"
            return next err if err
            console.log "end2"

            # there is already a track with the same name, give up
            if sameTracks.length > 0
                # Overwrite option is not fully implemented yet
                #
                #
                #if overwrite
                    #track = sameTracks[0]
                    #attributes =
                        #lastModification: lastModification
                        #size: part.byteCount
                        #mime: mime.lookup name
                        #class: getTrackClass part
                        #uploading: true
                    #return track.updateAttributes attributes, ->
                        ## Ask for the data system to not run autostop
                        ## while the upload is running.
                        #keepAlive()

                        ## Attach track in database.
                        #attachBinary track
                #else
                    upload = false
                    return res.send
                        error: true
                        code: 'EEXISTS'
                        msg: "This track already exists"
                    , 400

            # Generate track metadata.
            data =
                title: title
                artist: fields.artist
                album: fields.album
                trackNb: fields.trackNb
                year: fields.year
                genre: fields.genre
                time: fields.time
                docType: fields.dockType
                creationDate: now
                lastModification: lastModification
                size: part.byteCount
                uploading: true

            # check if the request is allowed
            # Not implemented yet
            # TODO: implement rights
            #confirmCanUpload data, req, (err) ->
                #return next err if err

                #TODO: change lastModification date playlist

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
