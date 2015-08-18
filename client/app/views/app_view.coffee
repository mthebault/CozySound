# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    app_view.coffee                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:07 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/18 15:58:36 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'
ContextMenu = require './context_menu'
LeftMenu = require './left_menu'
TracksScreen = require './tracks_screen'
PlayerScreen = require './player_screen'

module.exports = class AppView extends BaseView

    el: 'body.application'
    template: require('./templates/home')

    afterRender: ->
        # Create and render the context menu
        @contextMenu = new ContextMenu
        @$('#context-menu').append @contextMenu.$el
        @contextMenu.render()

        # Create and render the left menu
        @leftMenu = new LeftMenu
        @$('#left-menu').append @leftMenu.$el
        @leftMenu.render()

        # Create and render the tracks screen
        @tracksScreen = new TracksScreen
        @$('#tracks-screen').append @tracksScreen.$el
        @tracksScreen.render()

        # Create and render the player screen
        @playerScreen = new PlayerScreen
        @$('#player-screen').append @playerScreen.$el
        @playerScreen.render()

        console.log "write more code here !"

