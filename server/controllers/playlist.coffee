# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/27 16:21:05 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/28 22:18:41 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


module.exports.create = (req, res, next) ->
    console.log req.body
    res.status(200).send(req.body)

