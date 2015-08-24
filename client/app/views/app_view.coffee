# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    app_view.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:07 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/24 19:25:51 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'
ContextMenu = require './context_menu'
LeftMenu = require './left_menu'
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

    initialize: (options) ->
        super
        @selectedTracksList = options.selectedTracksList

    afterRender: ->
        # Create and render the context menu
        @contextMenu = new ContextMenu
            selectedTracksList: @selectedTracksList
        @$('#context-menu').append @contextMenu.$el
        @contextMenu.render()

        # Create and render the left menu
        @leftMenu = new LeftMenu
        @$('#left-menu').append @leftMenu.$el
        @leftMenu.render()


        # Create and render the player screen
        @playerScreen = new PlayerScreen
        @$('#player-screen').append @playerScreen.$el
        @playerScreen.render()

