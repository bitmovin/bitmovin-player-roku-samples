sub init()
  ' Creates the ComponentLibrary (the BitmovinPlayerSDK in this case)
  m.bitmovinPlayerSDK = CreateObject("roSGNode", "ComponentLibrary")
  m.bitmovinPlayerSDK.id = "BitmovinPlayerSDK"
  m.bitmovinPlayerSDK.uri = "https://cdn.bitmovin.com/player/roku/1/bitmovinplayer.zip"
  ' Adding the ComponentLibrary node to the scene will start the download of the library
  m.top.appendChild(m.bitmovinPlayerSDK)
  m.bitmovinPlayerSDK.observeField("loadStatus", "onLoadStatusChanged")

  ' Create the selection screen and data
  m.data = [
    {
      hls: "https://bitmovin-a.akamaihd.net/content/art-of-motion_drm/m3u8s/11331.m3u8",
      title: "Art of Motion"
    },
    {
      hls: "https://bitmovin-a.akamaihd.net/content/sintel/hls/sintel.m3u8",
      title: "Sintel"
    }
  ]

  m.SelectionRow = m.top.findNode("SelectionRow")
  rowData = CreateObject("roSGNode", "ContentNode")
  row = rowData.CreateChild("ContentNode")
  addRowItem(row, "pkg:/images/art-of-motion-poster.jpg")
  addRowItem(row, "pkg:/images/sintel-poster.jpg")
  m.SelectionRow.content = rowData

  m.SelectionRow.observeField("rowItemSelected", "onRowItemSelected")
  m.SelectionRow.setFocus(true)
end sub

sub addRowItem(row, poster)
  item = row.CreateChild("ContentNode")
  item.fhdPosterUrl = poster
end sub

sub onRowItemSelected(event as object)
  m.array = event.getData()
  source = m.data[m.array[1]]

  m.bitmovinplayer.callFunc(m.BitmovinFunctions.LOAD, source)
  m.bitmovinplayer.visible = true
end sub

sub onLoadStatusChanged()
  if m.bitmovinPlayerSDK.loadStatus = "ready"
    ' Once the player library is loaded and ready, we can use it to reference the BitmovinPlayer component
    m.bitmovinPlayer = CreateObject("roSGNode", "BitmovinPlayerSDK:BitmovinPlayer")
    m.bitmovinPlayer.visible = false
    m.top.appendChild(m.bitmovinPlayer)

    m.BitmovinFunctions = m.bitmovinPlayer.BitmovinFunctions
    m.BitmovinFields = m.bitmovinPlayer.BitmovinFields
    m.BitmovinPlayerState = m.bitmovinPlayer.BitmovinPlayerState
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.PLAYER_STATE, "onStateChange")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.ERROR, "onVideoError")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.SEEK, "onSeek")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.SEEKED, "onSeeked")
  end if
end sub

function onKeyEvent(key, press)
  if key = "back" and press and m.bitmovinplayer.visible = true
    m.bitmovinplayer.visible = false
    m.bitmovinplayer.callFunc(m.BitmovinFunctions.UNLOAD, invalid)
    m.SelectionRow.setFocus(true)
    return true
  end if

  return false
end function

' Player events

sub onStateChange()
  if m.bitmovinPlayer.playerState = m.BitmovinPlayerState.FINISHED
    print "Video has finished playing"
  end if
end sub

sub onSeek()
  print "SEEKING"
end sub

sub onSeeked()
  print "SEEKED: "; m.bitmovinPlayer.seeked
end sub

sub onVideoError()
  print "ERROR: "; m.bitmovinPlayer.error.code.toStr() + ": " + m.bitmovinPlayer.error.message
end sub
