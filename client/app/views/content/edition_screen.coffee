# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    edition_screen.coffee                              :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 19:28:24 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 19:30:15 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

EditionView = require './views/edition_view'


module.exports = class EditionScreen
    skeleton: require './skeletons/edition_skel'

    constructor: ->
        _.extend @, Backbone.Events

        @frame = $('#content-screen')

        @frame.html @skeleton()

        @view = new EditionView


    render: ->
        @view.render()


    attach: ->
        @view.render()
        @frame.append @view.el

    detach: ->
        @view.$el.detach()
