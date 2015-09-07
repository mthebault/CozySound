# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    app_view.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:07 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/07 20:16:07 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'
Menu = require '../models/menu_screen'
ContentScreen = require '../models/content_screen'
PlayerScreen = require './player_screen'

###
#  Represent the app context. It contain and lauch the four big parts:
#  - context menu
#  - left menu
#  - content screen
#  - player screen
###
module.exports = class AppView extends BaseView

    el: 'body.application'
    template: require './templates/home'

    afterRender: ->

        # Create and render the left menu
        @menuScreen = new Menu
        @menuScreen.render()

        # Create and render the player screen
        @playerScreen = new PlayerScreen
        @playerScreen.render()

        # Create and render the content screen
        @contentScreen = new ContentScreen
        @contentScreen.renderAllTracks()
