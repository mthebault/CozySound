# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    router.coffee                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:33 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/18 15:30:51 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

AppView = require 'views/app_view'

module.exports = class Router extends Backbone.Router

    routes:
        '': 'main'

    main: ->
        mainView = new AppView()
        mainView.render()
