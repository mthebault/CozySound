# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_menu_view.coffee                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/11 15:12:32 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 11:57:40 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../../lib/base_view'

module.exports = class PlaylistMenuView extends BaseView

    template: require '../templates/playlist_menu'
    el: '#playlist-menu'

    currentStatus: 'empty'

    events:
        'click #playlist-menu-remove-playlist': -> @trigger 'remove-current-playlist'
        'click #playlist-menu-remove-track': -> @trigger 'remove-track-playlist'

    afterRender: ->
        @menu = @$('#playlist-menu-button')
        @removeTrackButton =  @$('#playlist-menu-remove-track')

        @removeTrackButton.detach()


    ######################## ACTION TRACKS MENU #################################
    manageOptionsMenu: (status) =>
        if status == 'empty'
            if @currentStatus == 'several' || @currentStatus == 'unique'
                @removeTrackButton.detach()
            @currentStatus = status
        else if status == 'several' || status == 'unique'
            if @currentStatus == 'empty'
                @menu.append @removeTrackButton
            @currentStatus = status
    ################### END - ACTION TRACKS MENU - END ##########################



