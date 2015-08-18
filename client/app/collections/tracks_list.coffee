# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_list.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 18:42:03 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/18 18:51:06 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

module.exports = class TracksList extends Backbone.Collection
    model: Track
