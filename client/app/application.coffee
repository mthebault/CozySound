# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    application.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 03:26:02 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

module.exports =

    initialize: ->
        # Create a shortcut
        window.app = @


        # Used in inter-app communication
        #SocketListener = require '../lib/socket_listener'

        # Routing management
        Router = require 'router'
        @router = new Router()
        Backbone.history.start()

        # Makes this object immuable.
        Object.freeze this if typeof Object.freeze is 'function'
