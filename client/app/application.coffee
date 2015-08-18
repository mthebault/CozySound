# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    application.coffee                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:38 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/18 20:34:14 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

module.exports =

    initialize: ->
        # Create a shortcut
        window.app = @

        ######## Initialize Polyglot ############
        # Based on cozy-contact
        @locale = window.locale
        delete window.locale

        @polyglot = new Polyglot()

        try
            locales = require "locales/" + @locale
        catch err
            locales = require 'locales/en'

        # we give polyglot the data
        @polyglot.extend @locales

        # handy shortcut
        window.t = @polyglot.t.bind @polyglot

        ######## END - Initialize Polyglot - END ############

        # Used in inter-app communication
        #SocketListener = require '../lib/socket_listener'

        # Routing management
        Router = require 'router'
        @router = new Router()
        Backbone.history.start()

        # Makes this object immuable.
        Object.freeze this if typeof Object.freeze is 'function'
