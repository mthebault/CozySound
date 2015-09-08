# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    selected_list.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/05 19:01:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 22:27:10 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require './../models/track'

###
# SelectedList is a collection of Track model selected by the user. This Tracks
# are references to Tracks models contains in the Base collection. So all action
# on tracks must be handle by this list which update the Base Collection and the
# view.It's the same collection for all content screen (playlist/all tracks/etc...)
# which is refresh.
###
module.exports = class SelectedTracksList extends Backbone.Collection
    model: Track
    url: 'tracks'


    initialize: ->
        super
        # Create a shortcute for each track view can access to the selected
        # tracks list to trigger an event when they are selected
        window.selectedTracksList = @

    emptySelection: ->
        loop
            break if @length == 0
            @pop()
