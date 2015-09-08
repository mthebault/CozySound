# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    selection_list.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:06:43 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/08 23:29:20 by ppeltier         ###   ########.fr        #
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
module.exports = class SelectionList extends Backbone.Collection
    model: Track
    url: 'tracks'


    initialize: ->
        super
        # Create a shortcute for each track view can access to the selected
        # tracks list to trigger an event when they are selected
        window.selection = @

    emptySelection: ->
        loop
            break if @length == 0
            @pop()
