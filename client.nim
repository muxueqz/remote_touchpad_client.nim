import strutils
import jsffi
import dom
import jswebsockets
# window.addEventListener 'load', (->
  # authenticated = false
  # opening = document.getElementById('opening')
  # closed = document.getElementById('closed')
# proc challengeResponse(message: string): auto {. importcpp: "challengeResponse(#)" .}

# proc history_state(): string {. importcpp: "history" .}
var history {. importc, nodecl .}: JsObject
var console {. importc, nodecl .}: JsObject
proc btoa*(data: JsObject): cstring {.importcpp: "btoa(#)".}
proc handleStart*(ev: Event): JsObject {.importcpp: "handleStart(#)".}
proc handleEnd*(ev: Event): JsObject {.importcpp: "handleEnd(#)".}
proc handleCancel*(ev: Event): JsObject {.importcpp: "handleCancel(#)".}
proc handleMove*(ev: Event): JsObject {.importcpp: "handleMove(#)".}

proc jsSHA*(c_type, d_type: cstring): JsObject {.importcpp: "new jsSHA(#, #)".}
proc challengeResponse(message: cstring): cstring {.exportc.} =
    var shaObj = jsSHA("SHA-256", "TEXT")
    shaObj.setHMACKey(message, "TEXT")
    # var location_hash = $window.location.hash
    var location_hash = "#muxueqz"
    shaObj.update location_hash.substr(1)
    # shaObj.update(window.location.hash.substr(1))
    return btoa(shaObj.getHMAC("BYTES"))

# when isMainModule:
  # var socket = newWebSocket("ws://echo.websocket.org/")
#
  # socket.onopen = proc (e:Event) =
    # echo("sent: test")
    # socket.send("test")
  # socket.onmessage = proc (e:MessageEvent) =
    # echo("received: ",e.data)
    # socket.close(StatusCode(1000),"received msg")
  # socket.onclose = proc (e:CloseEvent) =
    # echo("closing: ",e.reason)

proc showScene(scene: string): auto =
  var scene_list = "opening closed pad keys keyboard".split(" ")
  echo "showScene: ", scene
  for e in scene_list:
    # echo e
    var element = document.getElementById(e)
    if e == scene:
      element.style.display = "flex"
    else:
      element.style.display = "none"

proc main() =
  var
    pad = document.getElementById("pad")
    padlabel = document.getElementById("padlabel")
    keys = document.getElementById("keys")
    keyboard = document.getElementById("keyboard")
    fullscreenbutton = document.getElementById("fullscreenbutton")
    text = document.getElementById("text")
    opening = document.getElementById("opening")
    closed = document.getElementById("closed")
    authenticated = false
    # var pad
    # echo "test"
  var ws = newWebSocket("ws://192.168.2.138:35921/ws")
  ws.onmessage = proc(event: MessageEvent) = 
    if authenticated:
      ws.close()
      return
    authenticated = true
    var r = challengeResponse(event.data)
    ws.send(r)
    # var history {. importc, nodecl .}: JsObject
    # var history.state {. importc, nodecl .}: JsObject
    var s = history.state.to(string)
    if s == "keyboard":
      echo s
    elif s == "keys":
      echo s
    else:
      showScene("pad")
  # if History.state == "keyboard":
    # echo "keyboard"
  ws.onclose = proc(event: CloseEvent) = 
    showScene("closed")
  window.onpopstate = proc (event: Event) =
    if pad.style.display != "none" or keyboard.style.display != "none" or keys.style.display != "none":
      var s = history.state.to(string)
      if s == "keys":
        echo "keys"
        # showKeys()
      # else if history.state == "keyboard"
        # showKeyboard()
      else:
        showScene "pad"

  # pad.addEventListener("touchstart",
    # proc (event: Event) =
      # discard handleStart(event)
    # ,
    # false)
  # pad.addEventListener("touchend",
    # proc (event: Event) =
      # discard handleEnd(event)
    # ,
    # false)
  # pad.addEventListener("touchcancel",
    # proc (event: Event) =
      # discard handleCancel(event)
    # ,
    # false)
  # pad.addEventListener("touchmove",
    # proc (event: Event) =
      # discard handleMove(event)
    # ,
    # false)

window.addEventListener("load",
    proc (event: Event) =
      # console.log challengeResponse("test")
      # window.alert("Hello World!")
      # text.value = ""
      showScene("opening")

    # ws = new WebSocket(wsProtocol + '//' + location.hostname + (location.port ? ':' + location.port : '') + '/ws');
      main()
  )
