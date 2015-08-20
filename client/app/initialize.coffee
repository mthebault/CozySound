# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    initialize.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:35 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/20 22:13:37 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

app = require 'application'

# The function called from index.html
$ ->
    require 'lib/app_helpers'

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


    # Keep count of the operations in progress
    window.pendingOperations =
        upload: 0

    app.initialize()
