# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    router.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:33 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/23 20:23:16 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

app = require 'application'
TracksView = require 'views/content/track/tracks_view'

module.exports = class Router extends Backbone.Router

    # contentView is a reference to the loaded collection
    contentView: null

    routes:
        '': 'main'

    # For the moment the view collection is recreate each time the page is
    # loaded
    main: ->
        @_loadAllTracks()


    _loadAllTracks: ->
        if not app.baseCollection.lenght > 0
            app.baseCollection.fetch
                error: (error) ->
                    console.log error
                success: (baseCollection) =>
                    @_renderAllTracks()
        else
            @_renderAllTracks()

    #TODO: optimise it
    _renderAllTracks: ->
        @contentView = new TracksView
            collection: app.baseCollection
        @contentView.render()


        console.log "update router"
