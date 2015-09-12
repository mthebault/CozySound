# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    view_collection.coffee                             :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:31:19 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 00:00:53 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require 'lib/base_view'

# View that display a collection of subitems
# used to DRY views
# Usage : new ViewCollection(collection:collection)
# Automatically populate itself by creating a itemView for each item
# in its collection

# can use a template that will be displayed alongside the itemViews

# itemView       : the Backbone.View to be used for items
# itemViewOptions : the options that will be passed to itemViews
# collectionEl : the DOM element's selector where the itemViews will
#                be displayed. Automatically falls back to el if null

module.exports = class ViewCollection extends BaseView

    itemview: null

    views: {}

    template: -> ''

    itemViewOptions: ->

    collectionEl: null

    # add 'empty' class to view when there is no subview
    onChange: ->
        @$el.toggleClass 'empty', _.size(@views) is 0

    # can be overriden if we want to place the subviews somewhere else
    appendView: (view) ->
        @$collectionEl.append view.el

    # bind listeners to the collection
    initialize: ->
        super
        @views = {}
        @listenTo @collection, "reset",   @onReset
        @listenTo @collection, "add",     @addItem
        @listenTo @collection, "remove",  @removeItem

        if not @collectionEl?
            collectionEl = el

    # if we have views before a render call, we detach them
    render: ->
        view.$el.detach() for id, view of @views
        super

    # after render, we reattach the views
    afterRender: ->
        @$collectionEl = $(@collectionEl)
        @appendView view.$el for id, view of @views
        @onReset @collection
        @onChange @views

    # destroy all sub views before remove
    remove: ->
        @onReset []
        super

    # event listener for reset
    onReset: (newcollection) ->
        view.remove() for id, view of @views
        newcollection.forEach @addItem

    # event listeners for add
    addItem: (model) =>
        options = _.extend {}, {model: model, collection: @}, @itemViewOptions(model)
        view = new @itemview(options)
        @views[model.cid] = view.render()
        @appendView view
        @onChange @views

    # event listeners for remove
    removeItem: (model) =>
        @views[model.cid].remove()
        delete @views[model.cid]

        @onChange @views



    # Manage event delegation. Events are listen to on the collection level,
    # then the callback are called on the view that originally triggered them.
    #
    # * `methodName` is the method that will be called on the View.
    # * `object` can be a File model or a DOMElement within FileView.$el
    viewProxy: (methodName, object) ->

        # Get view's cid. Views are indexed by cid. Object can be a File model
        # or a DOMElement within FileView.$el.
        if object.cid?
            cid = object.cid
        else
            cid = @$(object.target).parents('tr').data 'cid'

            unless cid?
                cid = @$(object.currentTarget).data 'cid'

        # Get the view.
        view = _.find @views, (view) -> view.model.cid is cid

        # In case of deletion, view may not exist anymore.
        if view?
            # Call `methodName` on the related view.
            args = [].splice.call arguments, 1
            view[methodName].apply view, args


