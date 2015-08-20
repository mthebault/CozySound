# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    router.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:33 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/20 22:46:13 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

app = require 'application'
TracksView = require 'views/content/track/tracks_view'

module.exports = class Router extends Backbone.Router

    # contentView is a reference to the loaded collection
    contentView: null

    routes:
        '': 'main'

    main: ->
        @_renderAllTracks()


    _renderAllTracks: ->
        if @contentView?
            @contentView.destroy()
        @contentView = @_loadAllTracks()
        @contentView.render()


    _loadAllTracks: ->
        if not @baseCollectionView?
            @baseCollectionView = new TracksView
               baseCollection:  app.baseCollection
               uploadQueue: app.uploadQueue
