# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    initialize.coffee                                  :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:35 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/18 15:30:49 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

app = require 'application'

# Inittialize the locale module for load the right language
# If the locale is not found we load english by default
#
initializeLocale = (locale) ->
    @locales = {}
    # if we don't find the appropiate locale file, it's English by default
    try
        @locales = require "locales/" + locale
    catch err
        @locales = require 'locales/en'

    @polyglot = new Polyglot()
    # we give polyglot the data
    @polyglot.extend @locales

    # handy shortcut
    window.t = @polyglot.t.bind @polyglot

# The function called from index.html
$ ->
    require 'lib/app_helpers'

    $.ajax 'cozy-locale.json',
        success: (data) ->
            locale = data.locale
            initializeLocale(locale)
        error: ->
            initializeLocale(locale)


    app.initialize()
