# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    router.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:33 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/25 16:45:49 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

app = require 'application'

module.exports = class Router extends Backbone.Router

    routes:
        '': 'main'

    # For the moment the view collection is recreate each time the page is
    # loaded
    main: ->
        if not app.baseCollection.lenght > 0
            app.baseCollection.fetch
                error: (error) ->
                    console.log error
