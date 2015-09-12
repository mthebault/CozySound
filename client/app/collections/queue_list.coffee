# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    queue_list.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/12 12:58:01 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 17:41:42 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

Track = require '../models/track'

module.exports = class QueueList extends Backbone.Collection
    model: Track


    addSelection: =>
        @selection = window.selection
        loop
            break if @selection.length == 0
            @add @selection.pop()
