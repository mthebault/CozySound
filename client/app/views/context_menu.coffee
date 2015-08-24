# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    context_menu.coffee                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:30:42 by ppeltier          #+#    #+#              #
#    Updated: 2015/08/24 13:47:47 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../lib/base_view'

# TODO: delete it
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

    events:
        # Event trigger when a user valid the files to upload
        'change #upload-files': 'lauchUploadFiles'

        # Bouton testing
        # TODO: delete it
        'click #fetch': 'fetchBaseCollection'


    afterRender: ->
        @uploader = $('#uploader')

    # Testing function
    # TODO: delete it
    fetchBaseCollection: ->
        console.log 'plop'
        window.app.baseCollection.fetch()

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
            window.app.uploadQueue.addBlobs files

            if event.target?
                target = $ event.target
                target.replaceWith target.clone true
