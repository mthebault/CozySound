# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    tracks_menu_view.coffee                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/08 23:09:44 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/09 12:03:20 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../../lib/base_view'

###
# Context_menu represent the menu on the top of the app. His goal is to work
# with tracks_display. It must display the dynamiques option when the user select
# one or several song in the tracks display.
###
module.exports = class TracksMenuView extends BaseView

    template: require '../templates/tracks_menu'
    el: '#tracks-menu'

    @statMenu = null

    events:
        # Event trigger when a user valid the files to upload
        'change #upload-files': 'lauchUploadFiles'
        # Lauch Tracks editions
        'click #menu-edit': (e) -> @trigger 'menu-trackEdition-lauch'

        # Bouton testing
        # TODO: delete it
        'click #menu-fetch': 'fetchBaseCollection'


    initialize: (options) ->
        @selection = options.selection

        @listPlaylists = window.app.playlistsCollection

        console.log 'playlists: ', @listPlaylists

    afterRender: ->
        @uploader = $('#uploader')

    # Testing function
    # TODO: delete it
    fetchBaseCollection: ->
        window.app.baseCollection.fetch()


    getRenderData: ->
        console.log 'playlists: ', @listPlaylists.models
        return {
            statMenu: @statMenu
            listPlaylists: @listPlaylists.models}


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
        @statMenu = status
        @render()
    ################### END - ACTION TRACKS MENU - END ##########################


