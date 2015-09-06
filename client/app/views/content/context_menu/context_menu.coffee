# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    context_menu.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/05 21:36:07 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../lib/base_view'
PlaylistList = require '../../../collections/playlists_list'


###
# Context_menu represent the menu on the top of the app. His goal is to work
# with tracks_display. It must display the dynamiques option when the user select
# one or several song in the tracks display.
###
module.exports = class ContextMenu extends BaseView

    el: '#context-menu'
    template: require './templates/context_menu'

    # Marquer is the action Menu is active or not
    trackMenuActive: false

    events:
        # Event trigger when a user valid the files to upload
        'change #upload-files': 'lauchUploadFiles'
        # Lauch Tracks editions
        'click #edit-tracks': (e) -> @trigger 'menu-trackEdition-lauch'

        # Bouton testing
        # TODO: delete it
        'click #fetch': 'fetchBaseCollection'


    afterRender: ->
        @uploader = $('#uploader')
        @$('#edit-tracks').hide()

    # Testing function
    # TODO: delete it
    fetchBaseCollection: ->
        window.app.baseCollection.fetch()




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
    manageActionTrackMenu: (isUsed)->
        if (isUsed == true)
            @$('#edit-tracks').show()
        else
            @$('#edit-tracks').hide()

    ################### END - ACTION TRACKS MENU - END ##########################

