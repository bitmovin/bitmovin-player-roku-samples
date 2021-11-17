sub main()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("PlayerExample")
  screen.show()

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent"
        if msg.isScreenClosed() then exit while
    end if
  end while
end sub
