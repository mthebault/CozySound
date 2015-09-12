# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    app_view.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:07 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 23:12:23 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'
MenuManager = require '../models/menu_manager'
ContentManager = require '../models/content_manager'
PlayerScreen = require './player/player_screen'

###
#  Represent the app context. It contain and lauch the four big parts:
#  - context menu
#  - left menu
#  - content screen
#  - player screen
###
module.exports = class AppView extends BaseView

    el: 'body.application'
    template: require './home'

    afterRender: ->

        # Create and render the left menu
        @menuScreen = new MenuManager
        @menuScreen.render()

        # Create and render the player screen
        @playerScreen = new PlayerScreen
        @playerScreen.render()

        # Create and render the content screen
        @contentScreen = new ContentManager
        @contentScreen.renderAllTracks()
