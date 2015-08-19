# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    base_view.coffee                                   :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:31:15 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/19 01:21:04 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

module.exports = class BaseView extends Backbone.View

    template: ->

    initialize: ->

    getRenderData: ->
        model: @model?.toJSON()

    render: ->
        @beforeRender()
        @$el.html @template(@getRenderData())
        @afterRender()
        @

    beforeRender: ->

    afterRender: ->

    destroy: ->
        @undelegateEvents()
        @$el.removeData().unbind()
        @remove()
        Backbone.View::remove.call @
