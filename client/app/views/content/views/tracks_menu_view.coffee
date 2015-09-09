# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_menu_view.coffee                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:09:44 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 16:03:35 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../../lib/base_view'
MenuListView = require './menu_list_view'

###
# Context_menu represent the menu on the top of the app. His goal is to work
# with tracks_display. It must display the dynamiques option when the user select
# one or several song in the tracks display.
###
module.exports = class TracksMenuView extends BaseView

    template: require '../templates/tracks_menu'
    el: '#tracks-menu'

    currentStatus: 'empty'

    events:
        # Event trigger when a user valid the files to upload
        'change #tracks-menu-uploadfiles': 'lauchUploadFiles'
        # Lauch Tracks editions
        'click #tracks-menu-edit': (e) -> @trigger 'menu-trackEdition-lauch'

        # Bouton testing
        # TODO: delete it
        'click #tracks-menu-fetch': 'fetchBaseCollection'



    initialize: (options) ->
        @selection = options.selection


    afterRender: ->
        @menu = $('#tracks-menu-button')
        @uploader = $('#tracks-menu-upload')
        @editionButton = $('#tracks-menu-edit')
        @playlistButton = $('#tracks-menu-playlist')

        @listPlaylistsViews = new MenuListView
        @listPlaylistsViews.render()

        @editionButton.detach()
        @playlistButton.detach()




    # Testing function
    # TODO: delete it
    fetchBaseCollection: ->
        window.app.baseCollection.fetch()


    addToPlaylist: (event) ->
        console.log 'event: ', event
        cid = @$(event.target).parents('li').data 'cid'
        console.log 'cid: ', cid



    ############################## UPLOAD #####################################
    # Catche all files in the event and send them to the uploadQueue collection
    lauchUploadFiles: (event) ->
        files = event.dataTransfert?.files or event.target.files
        if files.length
            window.app.uploadQueue.addBlobs files

            if event.target?
                target = $ event.target
                target.replaceWith target.clone true
    ########################## END - UPLOAD - END ###############################





    ######################## ACTION TRACKS MENU #################################
    # Check if the selection list is used or not. If it used the action track
    # menu pop in the context menu. If it's not used anymore the menu disapear
    # isUser is a bollean
    # TODO: improve it
    manageOptionsMenu: (status) =>
        if status == 'unique'
            if @currentStatus == 'empty'
                @menu.append @playlistButton
                @menu.append @editionButton
            else if @currentStatus == 'several'
                @menu.append @editionButton
            @currentStatus = status
        else if status == 'empty'
            if @currentStatus == 'unique'
                @editionButton.detach()
                @playlistButton.detach()
            else if @currentStatus == 'several'
                @playlistButton.detach()
            @currentStatus = status
        else if status == 'several'
            if @currentStatus == 'empty'
                @menu.append @playlistButton
            else if @currentStatus == 'unique'
                @editionButton.detach()
                @menu.append @playlistButton
            @currentStatus = status
    ################### END - ACTION TRACKS MENU - END ##########################



