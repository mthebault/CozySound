# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    context_menu.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/24 20:17:33 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'
app = require '../application'


###
# Context_menu represent the menu on the top of the app. His goal is to work
# with tracks_screen. It must display the dynamiques option when the user select
# one or several song in the tracks screen.
###
module.exports = class ContextMenu extends BaseView

    template: require('./templates/context_menu')
    tagName: 'div'
    className: 'context-menu'

    @trackMenuActive

    events:
        # Event trigger when a user valid the files to upload
        'change #upload-files': 'lauchUploadFiles'

        # Bouton testing
        # TODO: delete it
        'click #fetch': 'fetchBaseCollection'

    initialize: (options) ->
        super
        @selectedTracksList = options.selectedTracksList

        # Listen if a the selection collection is empty or not
        @listenTo @selectedTracksList, 'selectionTracksState', @manageActionTrackMenu

    afterRender: ->
        @uploader = $('#uploader')
        @$('#edit-tracks').hide()

    # Testing function
    # TODO: delete it
    fetchBaseCollection: ->
        app.baseCollection.fetch()

    ################## UPLOAD #########################

    # Catche all files in the event and send them to the uploadQueue collection
    lauchUploadFiles: (event) ->
        files = event.dataTransfert?.files or event.target.files
        # Debug log ###############################
        #
        #console.log 'Files to upload:'
        #console.log file for file in files
        #
        ##########################################
        if files.length
            app.uploadQueue.addBlobs files

            if event.target?
                target = $ event.target
                target.replaceWith target.clone true

    ######################## ACTION TRACKS MENU #################################
    # Check if the selection list is used or not. If it used the action track
    # menu pop in the context menu. If it's not used anymore the menu disapear
    # isUser is a bollean
    manageActionTrackMenu: (isUsed)->
        if (isUsed == true)
            @$('#edit-tracks').show()
        else
            @$('#edit-tracks').hide()

    ################### END - ACTION TRACKS MENU - END ##########################

