# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    initialize.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:35 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/18 20:24:52 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

app = require 'application'


# The function called from index.html
$ ->
    require 'lib/app_helpers'

    app.initialize()
