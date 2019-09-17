sub init()
  m.playerStateInfoGroup = m.top.findNode("playerStateInfoGroup")
  m.playerStateInfoBackground = m.top.findNode("playerStateInfoBackground")
  m.playerStateLabel = m.top.findNode("playerStateLabel")
  m.uiGroup = m.top.findNode("uiGroup")
  m.trickPlayThumbnail = m.top.findNode("trickPlayThumbnail")
  m.progressBar = m.top.findNode("progressBar")
  m.progressBarBackground = m.top.findNode("progressBarBackground")
  m.playerBackground = m.top.findNode("playerBackground")
end sub

sub initialize(params)
  deviceInfo = CreateObject("roDeviceInfo")
  resolutionInformation = deviceInfo.GetUIResolution()

  ' Set width and height for player state info background
  m.playerStateInfoBackground.width = resolutionInformation.width
  m.playerStateInfoBackground.height = resolutionInformation.height

  ' Calculate player width based on UI Resolution
  playerWidth = calculatePlayerWidth(resolutionInformation, 400)

  ' Set progress bar background and trick play background width
  m.playerBackground.width = playerWidth
  m.progressBarBackground.width = playerWidth - 50

  ' Set progress bar background translation
  xAxisProgressBarBackgroundPosition = getComponentXAxisParentCenter(playerWidth, m.progressBarBackground.width)
  yAxisProgressBarBackgroundPosition = getComponentYAxisParentCenter(m.playerBackground.height, m.progressBarBackground.height)
  m.progressBarBackground.translation = [xAxisProgressBarBackgroundPosition, yAxisProgressBarBackgroundPosition]

  'Set max values for width and height
  thumbnailScaleMax = {maxWidth: 400, maxHeight: 200}

  'Get scaled width and height for thumbnail poster
  thumbnailScaledValues = getScaledValues(resolutionInformation, thumbnailScaleMax)

  'Set thumbnail scaled width and height
  m.trickPlayThumbnail.width = thumbnailScaledValues.width
  m.trickPlayThumbnail.height = thumbnailScaledValues.height

  'set thumbnail translation
  xAxisTrickPlayThumbnailPosition = getComponentXAxisParentCenter(playerWidth, m.trickPlayThumbnail.width)
  m.trickPlayThumbnail.translation = [xAxisTrickPlayThumbnailPosition, 0]

  ' Set uiGroup visible to true and set translation based on UI Resolution
  offset = 100
  m.uiGroup.translation = getPlayerUiTranslation(resolutionInformation, offset)

  ' Set player state label translation
  xAxisPlayerStateLabel = m.uiGroup.boundingRect().width
  m.playerStateLabel.translation = [xAxisPlayerStateLabel, offset]

  m.uiGroup.visible = true
end sub

function calculatePlayerWidth(uiResolutionInfo, decriseByInt)
  width = uiResolutionInfo.width - decriseByInt

  return width
end function

function getScaledValues(uiResolutionInfo, maxValues)
  if uiResolutionInfo = invalid or maxValues = invalid
    return invalid
  end if

  uiResolutionName = uiResolutionInfo.name
  if uiResolutionName = "SD"
    percent = 60
  else if uiResolutionName = "HD"
    percent = 80
  else if uiResolutionName = "FHD"
    percent = 100
  end if

  width = percentToNumber(percent, maxValues.maxWidth)
  height = percentToNumber(percent, maxValues.maxHeight)

  scaledValues = {width: width, height: height}

  return scaledValues
end function

function getPlayerUiTranslation(uiResolutionInfo, offset)
  if uiResolutionInfo = invalid or offset = invalid
    return invalid
  end if
  deviceInfoUiWidth = uiResolutionInfo.width
  deviceInfoUiHeight = uiResolutionInfo.height

  playerUiWidth = m.uiGroup.boundingRect().width
  playerUiHeight = m.uiGroup.boundingRect().height
  x = getComponentXAxisParentCenter(deviceInfoUiWidth, playerUiWidth)
  y = deviceInfoUiHeight - playerUiHeight - offset

  return [x, y]
end function

sub setProgressBarWidth(videoTimeInfo)
  elapsedVideoPercent = calculateElapsedVideoPercent(videoTimeInfo.videoDuration, videoTimeInfo.currentVideoTime)
  progressBarWidth = percentToNumber(elapsedVideoPercent, m.progressBarBackground.width)

  m.progressBar.width = progressBarWidth
end sub

function calculateElapsedVideoPercent(duration, elapsedTime)
  percent = (elapsedTime / duration) * 100

  return percent
end function

sub setTrickPlayThumbnailUri(thumbnail)
  if thumbnail = invalid or thumbnail.url = invalid or not Len(thumbnail.url) > 0
    m.trickPlayThumbnail.uri = "pkg:/images/trickplay_placeholder_thumb.jpg"
  else
    ' Set previous image to be loadingBitmapUri to ensure smooth image change
    m.trickPlayThumbnail.loadingBitmapUri = m.trickPlayThumbnail.uri
    m.trickPlayThumbnail.uri = thumbnail.url
  end if

  setTrickPlayThumbnailVisibility(true)
end sub

sub setTrickPlayThumbnailVisibility(visible)
  if visible <> invalid
    m.trickPlayThumbnail.visible = visible
  end if
end sub

sub controlPlayerStateInfo(state)
  if(state <> "playing")
    m.playerStateInfoGroup.visible = true
    m.playerStateLabel.text = state
  else if state = "playing"
    m.playerStateInfoGroup.visible = false
    m.playerStateLabel.text = ""
  end if
end sub
