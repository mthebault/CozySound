# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    player_screen.coffee                               :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ppeltier <dev@halium.fr>                   +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2015/08/18 15:58:59 by ppeltier          #+#    #+#              #
#    Updated: 2015/09/13 01:27:52 by ppeltier         ###   ########.fr        #
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


    onTrackDbClick: (track, collection) ->
        @collection = collection
        @stopCurrentTrack()
        @lauchTrack track
        console.log 'track: ', track
        @trackIndex = _.findIndex @collection, (elem) => elem is track
        console.log 'track: ', @trackIndex

    lauchTrack: (track) ->
        if @status != 'stop'
            return
        console.log 'sound start'
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
        if @status is 'play' || @status is 'pause'
            @currentSound.destruct()
            @currentSound = null
            @queueList.shift()
            @status = 'stop'

    nextTrack: ->
        @currentSound.destruct()
        @currentSound = null
        @indexTrack++
        if not @indexTrack > @collection.length
            @lauchTrack @collection[indexTrack]

    prevTrack: ->
        @currentSound.destruct()
        @currentSound = null
        @queueList.shift()
        if @queueList.length > 0
            @playTrack()
        else
            @status = 'stop'

