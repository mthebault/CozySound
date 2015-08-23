# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    router.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:33 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/23 16:19:52 by ppeltier         ###   ########.fr        #
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
        @_loadAllTracks()


    _loadAllTracks: ->
        #if not app.baseCollection.lenght > 0
        app.baseCollection.fetch
            error: (error) ->
                console.log error
            success: (baseCollection) ->
                console.log 'fetch base collection: ', app.baseCollection
                @plop = new TracksView
                    collection: app.baseCollection
                console.log 'collectionView: ', @plop
                #@contentView = app.baseCollectionView
                #@contentView.render()
                @plop.render()
