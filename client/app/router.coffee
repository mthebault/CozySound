# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    router.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:33 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/24 17:45:03 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

app = require 'application'

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
        @_renderAllTracks()
        if not app.baseCollection.lenght > 0
            app.baseCollection.fetch
                error: (error) ->
                    console.log error

    _renderAllTracks: ->
        @contentView = app.baseCollectionView
        @contentView.render()
