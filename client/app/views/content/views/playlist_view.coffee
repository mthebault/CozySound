# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    playlist_view.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/09/09 17:16:36 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/10 11:32:18 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../../../lib/base_view'

module.exports = class PlaylistView extends BaseView
    template: require '../templates/playlist'

    el: '#playlist-header'

    events: ->
        'click #playlist-send-name': 'changePlaylistName'


    initialize: (options) ->
        @playlist = options.playlist
        @listenTo @playlist, 'change:name', @render

    getRenderData: ->
        return {playlist: @playlist.toJSON()}


    changePlaylistName: ->
        data = @$('#playlist-change-name').val()
        @playlist.set 'name', data
        @playlist.save()
