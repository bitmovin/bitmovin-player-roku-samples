sub init()
  m.playerConfig = getPlayerConfigWithSideloadedThumbnailTrack()

  ' Creates the ComponentLibrary (the BitmovinPlayerSDK in this case)
  m.bitmovinPlayerSDK = CreateObject("roSGNode", "ComponentLibrary")
  m.bitmovinPlayerSDK.id = "BitmovinPlayerSDK"
  m.bitmovinPlayerSDK.uri = "https://cdn.bitmovin.com/player/roku/1/bitmovinplayer.zip"

  ' Adding the ComponentLibrary node to the scene will start the download of the library
  m.top.appendChild(m.bitmovinPlayerSDK)
  m.bitmovinPlayerSDK.observeField("loadStatus", "onLoadStatusChanged")

  ' Init duration and currentTime AssocArray
  m.durationAndCurrentTime = {}

  m.BackgroundRunningTask = m.top.findNode("BackgroundRunningTask")
  m.BackgroundRunningTask.control = "run"

  m.BackgroundRunningTask.ObserveField("downloadSpriteResponse", "onDownloadSpriteResponse")
  m.BackgroundRunningTask.ObserveField("writeImageResponse", "onWriteImageResponse")
  setDefaultsForSprite()
end sub

' The ComponentLibrary loadStatus field can equal "none", "ready", "loading" or "failed"
sub onLoadStatusChanged()
  print "LOAD STATUS FOR LIBRARY: "; m.bitmovinPlayerSDK.loadStatus
  if (m.bitmovinPlayerSDK.loadStatus = "ready")
    ' Once the player library is loaded and ready, we can use it to reference the BitmovinPlayer component
    m.bitmovinPlayer = CreateObject("roSGNode", "BitmovinPlayerSDK:BitmovinPlayer")
    m.BitmovinFunctions = m.bitmovinPlayer.BitmovinFunctions
    m.BitmovinFields = m.bitmovinPlayer.BitmovinFields
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.ERROR, "onError")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.WARNING, "onWarning")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.CURRENT_TIME, "onCurrentTimeChanged")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.SOURCE_LOADED, "onSourceLoaded")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.SOURCE_UNLOADED, "onSourceUnloaded")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.PLAY, "onPlay")
    m.bitmovinPlayer.ObserveField(m.BitmovinFields.PLAYER_STATE, "onPlayerState")

    m.top.appendChild(m.bitmovinPlayer)

    m.bitmovinPlayer.setFocus(true)

    m.bitmovinPlayer.callFunc(m.BitmovinFunctions.SETUP, m.playerConfig)

    ' Adding the "UiExample" as the basic custom player UI
    m.playerUi = CreateObject("roSGNode", "UiExample")
    m.playerUi.id = "playerUi"
    m.top.appendChild(m.playerUi)
    m.playerUi.callFunc("initialize", invalid)
  end if
end sub

sub onError()
  print "ERROR: "; m.bitmovinPlayer.error.code.toStr() + ": " + m.bitmovinPlayer.error.message
end sub

sub onWarning()
  print "WARNING: "; m.bitmovinPlayer.warning.code.toStr() + ": " + m.bitmovinPlayer.warning.message
end sub

sub onCurrentTimeChanged()
  print "CURRENT TIME: "; m.bitmovinPlayer.currentTime

  ' Set playerUi progress bar width based on video duration and current Time
  m.durationAndCurrentTime = getDurationAndCurentTime()
  m.playerUi.callFunc("setProgressBarWidth", m.durationAndCurrentTime)
end sub

sub onSourceLoaded()
  print "SOURCE LOADED"
end sub

sub onSourceUnloaded()
  print "SOURCE UNLOADED"
  m.BackgroundRunningTask.deleteImage = m.downloadedSpritePath
  setDefaultsForSprite()
end sub

sub onPlay()
  print "PLAY"
end sub

sub onPlayerState()
  if m.playerUi <> invalid
    m.playerUi.callFunc("controlPlayerStateInfo", m.bitmovinPlayer.playerState)
  end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  handled = false
  if press = true
    if key = "fastforward"
      setTrickPlayThumbnailAndProgressBarWidth(key, 5)
      handled = true
    else if key = "rewind"
      setTrickPlayThumbnailAndProgressBarWidth(key, 5)
      handled = true
    else if key = "OK"
      m.bitmovinPlayer.callFunc(m.BitmovinFunctions.SEEK, m.durationAndCurrentTime.currentVideoTime)
      m.playerUi.callFunc("setTrickPlayThumbnailVisibility", false)
      handled = true
    end if
  end if

  return handled
end function

function getDurationAndCurentTime()
  duration = m.bitmovinPlayer.callFunc(m.BitmovinFunctions.GET_DURATION, invalid)
  currentTime = m.bitmovinPlayer.currentTime

  return {videoDuration: duration, currentVideoTime: currentTime}
end function

sub setTrickPlayThumbnailAndProgressBarWidth(key, seekInterval)
  if m.bitmovinPlayer.playerState <> "stalling"
    m.bitmovinPlayer.callFunc(m.BitmovinFunctions.PAUSE, invalid)

    if key = "fastforward"
      seekTime = m.durationAndCurrentTime.currentVideoTime + seekInterval
      if seekTime > m.durationAndCurrentTime.videoDuration
        seekTime = m.durationAndCurrentTime.videoDuration
      end if
    else key = "rewind"
      seekTime = m.durationAndCurrentTime.currentVideoTime - seekInterval
      if seekTime < 0
        seekTime = 0
      end if
    end if

    m.durationAndCurrentTime.currentVideoTime = seekTime

    ' Get thumbnail object
    thumbnail = m.bitmovinPlayer.callFunc(m.BitmovinFunctions.GET_THUMBNAIL, m.durationAndCurrentTime.currentVideoTime)
    if thumbnail <> invalid
      if isSameSpriteUrl(m.activeSpriteDownloadUrl, thumbnail.url) = false and m.spriteDownloaded = true
        m.BackgroundRunningTask.deleteImage = m.downloadedSpritePath
        m.spriteDownloaded = false
      end if

      if m.spriteDownloaded = false
        m.BackgroundRunningTask.downloadSprite = {downloadSpriteToLocation: m.downloadedSpritePath, thumbnail: thumbnail}
      else
        thumbnailUpdated = thumbnailImageUpdate(thumbnail, m.playerUi, m.downloadedSpritePath)
      end if
      m.activeSpriteDownloadUrl = thumbnail.url
    end if
    m.playerUi.callFunc("setProgressBarWidth", m.durationAndCurrentTime)
  end if
end sub

function isSameSpriteUrl(activeSpriteUrl, nextSpriteUrl)
  if activeSpriteUrl <> nextSpriteUrl
    return false
  end if

  return true
end function

sub onDownloadSpriteResponse()
  response = m.BackgroundRunningTask.downloadSpriteResponse
  sucess = response.sucess
  thumbnail = response.thumbnail
  if sucess = true
    m.spriteDownloaded = sucess
    thumbnailImageUpdate(thumbnail, m.playerUi, m.downloadedSpritePath)
  end if
end sub

sub thumbnailImageUpdate(thumbnail, playerUi, spritePath)
    m.BackgroundRunningTask.deleteImage = playerUi.callFunc("getTrickPlayThumbnailUri", invalid)
    m.BackgroundRunningTask.writeImage = {spritePath: spritePath, thumbnail: thumbnail}
end sub

sub onWriteImageResponse()
  response = m.BackgroundRunningTask.writeImageResponse
  if response.sucess = true
    thumbnail = response.thumbnail
    m.playerUi.callFunc("setTrickPlayThumbnailUri", thumbnail)
  end if
end sub

sub setDefaultsForSprite()
  m.spriteDownloaded = false
  m.downloadedSpritePath = "tmp:/sprite.png"
  m.activeSpriteDownloadUrl = ""
end sub
