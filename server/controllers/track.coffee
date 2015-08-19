# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/19 06:50:00 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 07:26:16 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

multiparty = require 'multiparty'

# Prior to file creation it ensures that all parameters are correct and that no
# file already exists with the same name. Then it builds the track document from
# given information and uploaded file metadata. Once done, it performs all
# database operation and index the track name. Finally, it tags the file if the
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

module.exports.create = (req, res, next) ->
    clearTimeout(timeout) if timeout?


    fields = {}

    # Parse given form to extract image blobs
    form = new multiparty.Form()

    form.on 'part', (part) ->
    # Get field, form is processed one way, be sure that fields are sent
        # before the file.
        # Parts are processed sequentially, so the data event should be
        # processed before reaching the file part.
        unless part.filename?
            fields[part.title] = ''
            part.on 'data', (buffer) ->
                fields[part.title] = buffer.toString()
            return

        console.log 'fields: ', fields

        # We assume that only one file is sent.
        # we do not write a subfunction because it seems to load the whole
        # stream in memory.
        title = fields.title
        lastModification = moment(new Date(fields.lastModification)).toISOString()
        overwrite = fields.overwrite
        upload = true
        canceled = false
        uploadStream = null

        # we have no title for this file, give up
        if not title or title is ""
            err = new Error "Invalid arguments: no title given"
            err.status = 400
            return next err

        # while this upload is processing
        # we send usage.application to prevent auto-stop
        # and we defer parents lastModification update
        keepAlive = ->
            if upload
                feed.publish 'usage.application', 'files'
                setTimeout keepAlive, 60*1000
                resetTimeout()

        # if anything happens after the file is created
        # we need to destroy it
        rollback = (file, err) ->
            canceled = true
            file.destroy (delerr) ->
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


        attachBinary = (file) ->
            # request-json requires a path field to be set
            # before uploading
            part.path = file.title
            checksum = crypto.createHash 'sha1'
            checksum.setEncoding 'hex'
            part.pause()
            part.pipe checksum
            metadata = name: "file"
            uploadStream = file.attachBinary part, metadata, (err) ->
                upload = false
                # rollback if there was an error
                return rollback file, err if err #and not canceled

                # TODO move everythin below in the model.
                checksum.end()
                checksum = checksum.read()

                # set the file checksum

                unless canceled

                    data =
                        checksum: checksum
                        uploading: false

                    file.updateAttributes data, (err) ->
                        # we ignore checksum storing errors
                        log.debug err if err

                        # index the file in cozy-indexer for fast search
                        file.index ["name"], (err) ->
                            # we ignore indexing errors
                            log.debug err if err

                            # send email or notification of file changed
                            who = req.guestEmail or 'owner'
                            sharing.notifyChanges who, file, (err) ->

                                # we ignore notification errors
                                log.debug err if err

                                # Retrieve binary metadat
                                File.find file.id, (err, file) ->
                                    log.debug err if err
                                    res.send file, 200

        now = moment().toISOString()
