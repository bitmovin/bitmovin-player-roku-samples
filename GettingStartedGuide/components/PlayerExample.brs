sub init()
  ' Add the player SDK to your project using a component library
  m.bitmovinPlayerSDK = CreateObject("roSGNode", "ComponentLibrary")
  m.bitmovinPlayerSDK.id = "BitmovinPlayerSDK"
  m.bitmovinPlayerSDK.uri = "https://cdn.bitmovin.com/player/roku/1/bitmovinplayer.zip"

  ' Start the download of the component library by adding it to your scene and check for the download being finished by observing the loadStatus field.
  m.top.appendChild(m.bitmovinPlayerSDK)
  m.bitmovinPlayerSDK.observeField("loadStatus", "onLoadStatusChanged")
end sub

sub onLoadStatusChanged()
  ' Once the download of the library is complete you can create an instance of the player.
  if (m.bitmovinPlayerSDK.loadStatus = "ready")
    m.bitmovinPlayer = CreateObject("roSGNode", "BitmovinPlayerSDK:BitmovinPlayer")

    ' For ease of use we recommend using our function and field enums
    m.BitmovinFunctions = m.bitmovinPlayer.BitmovinFunctions
    m.BitmovinFields = m.bitmovinPlayer.BitmovinFields

    ' Create a player config to configure the player to your needs.
    m.playerConfig = {
      playback: {
        autoplay: true,
        muted: false
      },
      adaptation: {
        preload: true
      },
      ' key: "YOUR_LICENCE_KEY" ' The licence key is only required here if it wasn't added in the manifest as described in step 1.
    }

    ' Pass the created player config to the player using the setup call.
    m.bitmovinPlayer.callFunc(m.BitmovinFunctions.SETUP, m.playerConfig)

    ' Create a source config consisting of at least a stream url with the corresponding format and a title to be passed to the player.
    m.sourceConfig = {
      dash: "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd",
      title: "My Video"
    }

    ' Load the created source config into the player using the load call.
    m.bitmovinPlayer.callFunc(m.BitmovinFunctions.LOAD, m.sourceConfig)

    ' Append the player to the scene and set the focus on it.
    m.top.appendChild(m.bitmovinPlayer)
    m.bitmovinPlayer.setFocus(true)
  end if
end sub
