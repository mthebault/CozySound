# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    player_screen.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:58:59 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 02:51:20 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../lib/base_view'

# Context_menu represent the menu on the top of the app. His goal is to work
# with tracks_screen. It must display the dynamiques option when the user select
# one or several song in the tracks screen.
module.exports = class PlayerScreen extends BaseView

    template: require('./templates/player_screen')
    el: '#player-screen'

    volume: 50
    currentSound: null

    currentTrack: null

    trackIndex: null

    collection: null

    status: 'stop'

    initialize: ->
        window.app.player = @
        @queueList = window.app.queueList
        @soundManager = window.app.soundManager

    events:
        'click #player-play': 'onClickPlay'
        'click #player-stop': 'stopTrack'
        'click #player-next': 'nextTrack'

    onReady: ->
        console.log 'ready'


    onTimeout: ->
        console.log 'timeout'


    onTrackDbClick: (track) ->
        @stopCurrentTrack()
        @lauchTrack track
        @collection = window.app.contentManager.getPrintedCollection()
        index = 0
        loop
            break if index == @collection.length
            if @collection.at(index) == track
                @trackIndex = index
                return
            index++



    lauchTrack: (track) ->
        track.markAsPlayed()
        @currentTrack = track
        @currentSound = @soundManager.createSound
            id: "sound-#{track.id}"
            url: "track/binary/#{track.id}"
            usePolicyFile: true
            autoPlay: true
            onfinish: @nextTrack
            #onstop: @onTrackStop
            multiShot: false
        @status = 'play'

    pauseTrack: ->
        @currentSound.pause()
        @status = 'pause'


    stopCurrentTrack: ->
        @currentTrack?.markAsNoPlayed()
        if @status is 'play' || @status is 'pause'
            @currentSound.destruct()
            @currentSound = null
            @status = 'stop'

    nextTrack: ->
        @stopCurrentTrack()
        @trackIndex++
        if @trackIndex < @collection.length
            console.log 'index: ', @trackIndex, ' / length: ', @collection.length
            @lauchTrack @collection.at @trackIndex

    prevTrack: ->
        @stopCurrentTrack()
        if @trackIndex > 0
            @trackIndex--
            console.log 'index: ', @trackIndex
            @lauchTrack @collection.at @trackIndex

