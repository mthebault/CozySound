# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    track.coffee                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 22:06:02 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 05:35:18 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

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
