sub init()
  m.top.functionName = "runTask"
end sub

Sub runTask()
  port = CreateObject("roMessagePort")
  m.top.observeFieldScoped("downloadSprite", port)
  m.top.observeFieldScoped("writeImage", port)
  m.top.observeFieldScoped("deleteImage", port)
  m.pendingTransfer = {}

  while true
    message = wait(0, port)
    messageType = type(message)
    if messageType = "roSGNodeEvent"
      field = message.getField()
      if field = "writeImage"
        m.top.writeImageResponse = writeImageToDisk(m.top.writeImage)
      else if field = "deleteImage"
        DeleteFile(m.top.deleteImage)
      else if field = "downloadSprite"
        downloadSpriteData = m.top.downloadSprite
        request = createRequest(downloadSpriteData.thumbnail.url, port)
        request.AsyncGetToFile(downloadSpriteData.downloadSpriteToLocation)
        requestIdentity = request.GetIdentity().toStr()
        m.pendingTransfer[requestIdentity] = request
      end if
    else if messageType = "roUrlEvent"
      responseCode = message.getResponseCode()
      eventIdentity = message.GetSourceIdentity().toStr()
      currentRequest = m.pendingTransfer[eventIdentity]
      if currentRequest <> invalid
        downloadSpriteResponse = {sucess: false, thumbnail: invalid }
        if responseCode = 200
          downloadSpriteResponse.sucess = true
          downloadSpriteResponse.thumbnail = downloadSpriteData.thumbnail
        end if
        m.pendingTransfer.Delete(eventIdentity)
        m.top.downloadSpriteResponse = downloadSpriteResponse
      end if
    end if
  end while
End Sub

function writeImageToDisk(writeImageData)
  spritePath = writeImageData.spritePath
  thumbnail = writeImageData.thumbnail
  imagePath = "tmp:/trickPlayThumbnail" + Rnd(10000).toStr() + ".png"
  spriteBitmap = CreateObject("roBitmap", spritePath)

  image = spriteBitmap.GetPng(thumbnail.x, thumbnail.y, thumbnail.w, thumbnail.h)
  if image <> invalid
    saveImage = image.WriteFile(imagePath)
  else
    saveImage = false
  end if

  writeImageResponse = {sucess: false, thumbnail: invalid }
  if saveImage = true
    writeImageResponse.sucess = true
    thumbnail.url = imagePath
    writeImageResponse.thumbnail = thumbnail
  end if

  return writeImageResponse
end function

function createRequest(url, port)
  request = CreateObject("roUrlTransfer")
  request.SetCertificatesFile("common:/certs/ca-bundle.crt")
  request.SetUrl(url)
  request.SetPort(port)

  return request
end function
