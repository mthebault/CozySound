# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    queue_prev_list.coffee                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/13 17:23:24 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 19:11:04 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


Track = require './../models/track'

module.exports = class QueuePrevList extends Backbone.Collection
    model: Track

