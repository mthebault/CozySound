# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 22:06:02 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/23 17:51:28 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

###
# Represent a track element contained in the base collection
#
#
# # uploadStatus Flag:
#       In case of upload, the upload queue parse the metadata, and push it to
#       the queue and the base collection so it is directly prompt to the user.
#       The upload flag permit to the user to follow the uploading process and
#       cancel it. Each modification of this flag is warn by the triggering of
#       the 'change'.
###
module.exports = class Track extends Backbone.Model
    url: 'track'

    #TODO: handle event 'change'


    # Local state. Handled through `markAs*` and `is*` methods.
    uploadStatus: null

    # Local stat. Handled throught nothing for the moment
    error: null

    # Valid values for `uploadStatus`.
    # Check if conflic must be handled
    @VALID_STATUSES: [null, 'uploading', 'uploaded', 'errored']#, 'conflict']

    ###
    # Getters for the local state.
    ###
    isUploading: -> return @uploadStatus is 'uploading'
    isUploaded: -> return @uploadStatus is 'uploaded'
    isErrored: -> return @uploadStatus is 'errored'
    isConflict: -> return @uploadStatus is 'conflict'

    ###
    # Setters for the local state. Semantic wrapper for _setUploadStatus.
    ###
    markAsUploading: -> @_setUploadStatus 'uploading'
    markAsUploaded: -> @_setUploadStatus 'uploaded'
    markAsConflict: -> @_setUploadStatus 'conflict'
    markAsErrored: (error) -> @_setUploadStatus 'errored', error


    ###
        Trigger change for each status update because Backbone only triggers
        `change` events for model's attributes.
        The `change` events allow the projection to be updated.
        @param `status` must be in Track.VALID_STATUSES
    ###
    _setUploadStatus: (status, error = null) ->
        if status not in Track.VALID_STATUSES
            message = "Invalid upload status #{status} not " + \
                      "in #{Track.VALID_STATUSES}"
            throw new Error message
        else
            @error = error
            @uploadStatus = status
            @trigger 'change', @

    # Returns an existing model if a track with a similar id or a similar
    # tack is already in the queue.
    isTrackStored: (model) ->

        # first check by id
        existingTrack = @get model.get('id')

        # TODO: make the comparisons

        return existingTrack or null

    # Overrides sync method to allow track upload (multipart request)
    # and progress events call with save methode
    sync: (method, model, options) =>


        # this is a new model, let's upload it as a multipart
        if model.track

            # if the track is being overwritten (update), we force
            # the "create" method, since only the "create" action in the server
            # can handle track upload.
            method = 'create'
            @id = ""

            formdata = new FormData()
            formdata.append 'title', model.get 'title'
            formdata.append 'artist', model.get 'artist'
            formdata.append 'album', model.get 'album'
            formdata.append 'trackNb', model.get 'trackNb'
            formdata.append 'year', model.get 'year'
            formdata.append 'genre', model.get 'genre'
            formdata.append 'time', model.get 'time'
            formdata.append 'docType', model.get 'docType'
            formdata.append 'lastModification', model.get 'lastModification'
            formdata.append 'overwrite', true if @overwrite
            formdata.append 'track', model.track

            # trigger upload progress on the model
            progress = (e) ->
                model.loaded = e.loaded
                model.trigger 'progress', e

            _.extend options,
                contentType: false
                data: formdata
                # patch Model.sync so it could trigger progress event
                xhr: =>
                    xhr = $.ajaxSettings.xhr()
                    if xhr.upload
                        xhr.upload.addEventListener 'progress', progress, false
                        @uploadXhrRequest = xhr
                    xhr

        Backbone.sync.apply @, arguments
