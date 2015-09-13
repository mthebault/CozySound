# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    player_screen.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:58:59 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 19:31:43 by ppeltier         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BaseView = require '../../lib/base_view'

module.exports = class PlayerScreen extends BaseView

    template: require('./templates/player_screen')
    el: '#player-screen'

    volume: 50
    currentSound: null

    currentTrack: null

    status: 'stop'

    initialize: ->
        window.app.player = @
        @queue = window.app.queue
        @queuePrev = window.app.queuePrev
        @soundManager = window.app.soundManager
        @allTracks =  window.app.baseCollection

    events:
        'click #player-play': 'onClickPlay'
        'click #player-next': 'nextTrack'
        'click #player-prev': 'prevTrack'

    onReady: ->
        console.log 'ready'


    onTimeout: ->
        console.log 'timeout'


    onClickPlay: ->
        if not @currentTrack?
            if @queue.length == 0
                @queue.populate 0, 'allTracks', @allTracks
            @currentTrack = @queue.shift()
            @lauchTrack()
        else if @status == 'play'
            @pauseTrack()
        else if @status == 'pause'
            @currentSound.play()
            @status = 'play'

    onTrackDbClick: (track) ->
        if @currentTrack?
            @stopCurrentTrack()
            @queuePrev.unshift @currentTrack

        {collection, name} = window.app.contentManager.getPrintedCollection()

        if name == 'queue'
            @queue.jumpInQueue track
        else
            index = 0
            loop
                break if index > collection.length || collection.at(index) == track
                index++
            @queue.populate index, name, collection

        @currentTrack = @queue.shift()
        @lauchTrack()



    lauchTrack: ->
        if not @currentTrack?
            console.log 'no track'
            return
        @status = 'play'
        @currentTrack.markAsPlayed()
        @currentSound = @soundManager.createSound
            id: "sound-#{@currentTrack.id}"
            url: "track/binary/#{@currentTrack.id}"
            usePolicyFile: true
            autoPlay: true
            onfinish: @nextTrack
            onstop: @stopCurrentTrack
            multiShot: false

    pauseTrack: ->
        @currentSound.pause()
        @status = 'pause'


    stopCurrentTrack: ->
        @currentTrack?.markAsNoPlayed()
        if (@status is 'play' || @status is 'pause') && @currentSound?
            @currentSound.destruct()
            @currentSound = null
        @status = 'stop'

    nextTrack: =>
        @stopCurrentTrack()
        @queuePrev.unshift @currentTrack
        @currentTrack = @queue.shift()
        @lauchTrack()

    prevTrack: ->
        @stopCurrentTrack()
        @queue.unshift @currentTrack
        @currentTrack = @queuePrev.shift()
        @lauchTrack()

