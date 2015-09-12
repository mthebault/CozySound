# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    player_screen.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:58:59 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/12 23:05:34 by ppeltier         ###   ########.fr        #
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

    status: 'stop'

    initialize: ->
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


    onClickPlay: ->
        switch @status
            when 'stop' then @playTrack()
            when 'play' then @pauseTrack()
            when 'pause' then @currentSound.play()


    playTrack: ->
        console.log 'sound start'
        if @queueList.length == 0
            return
        track = @queueList.at 0
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


    stopTrack: ->
        if @status is 'play' or 'pause'
            @currentSound.destruct()
            @currentSound = null
            @queueList.shift()
            @status = 'stop'

    nextTrack: ->
        @currentSound.destruct()
        @currentSound = null
        @queueList.shift()
        if @queueList.length > 0
            @playTrack()
        else
            @status = 'stop'

    prevTrack: ->
        @currentSound.destruct()
        @currentSound = null
        @queueList.shift()
        if @queueList.length > 0
            @playTrack()
        else
            @status = 'stop'

