do ->
    
    # reference all elements
    cubeElm = document.querySelector("#cube")
    trackAVolumeElm = document.querySelector("#trackA-valume")
    trackAPanElm = document.querySelector("#trackA-pan")
    trackBVolumeElm = document.querySelector("#trackB-valume")
    trackBPanElm = document.querySelector("#trackB-pan")
    introElm = document.querySelector("#intro")

    # play two tracks, fade them in and loop them
    trackA = new Howl({
        urls: ['sounds/trackA.mp3']
        autoplay: true
        loop: true
    })

    trackA.fade(0, 1, 5000)

    trackB = new Howl({
        urls: ['sounds/trackB.mp3']
        autoplay: true
        loop: true
    })

    trackB.fade(0, 1, 5000)

    # stat leap motion tracking
    leapCtrl = new Leap.Controller({ enableGestures: true }).connect()

    # on every frame
    leapCtrl.on('frame', (frame) ->

        # hide intro when hands entet
        if frame.hands.length
            introElm.className = 'fade-out'

        # read both hands
        frame.hands.forEach( (hand) ->

            # get hand position and convert it's
            # up/dpwn position to volume
            trackVolume = convertToVolume(hand.stabilizedPalmPosition[1])

            # get roll value in range of -1 to 1
            trackPan = -Math.min(Math.max(parseFloat(hand.roll()).toFixed(1), -1), 1)

            # set A or B track volume based on hand type
            if hand.type is 'left'
                track = trackA
                trackVolumeElm = trackAVolumeElm
                trackPanElm = trackAPanElm
            else
                track = trackB
                trackVolumeElm = trackBVolumeElm
                trackPanElm = trackBPanElm

            track.volume(trackVolume).pos3d(trackPan, 0, 0)

            # get average volume
            averageVolume = (trackA.volume() + trackB.volume()) / 2

            # get cube opacity based on average volume
            cube.style.opacity = averageVolume

            # update volume display
            trackVolumeElm.innerHTML = Math.round(trackVolume * 100)
            trackVolumeElm.style.opacity = trackVolume + 0.1

            # update pan display
            trackPanElm.innerHTML = trackPan
            trackPanElm.style.opacity = trackVolume + 0.1

        )
    )

    # conver to volume
    convertToVolume = (leapValue) ->
        appEnd = 100
        leapStart = 100
        leapEnd = 300
        leapRange = leapEnd - leapStart

        return Math.round(Math.min(Math.max(leapValue - leapStart, 0) * (appEnd / leapEnd), 100)) / 100
