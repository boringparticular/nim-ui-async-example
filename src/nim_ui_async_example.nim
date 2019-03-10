import ui
import asyncdispatch

var label: Label
var doCount = false

proc asyncProc {.async.} =
  var counter = 1
  while doCount:
    label.text = "Counter: " & $counter
    inc(counter)
    await sleepAsync 500

proc pollAsyncEvents(timeout: int) =
  try:
    poll(timeout)
  except ValueError:
    # No pending operations
    discard
  except:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got exception ", repr(e), " with message ", msg

proc main*() =
  var mainwin: Window

  mainwin = newWindow("async example", 640, 480, true)
  mainwin.margined = true
  mainwin.onClosing = (proc (): bool = return true)

  let box = newVerticalBox(true)
  mainwin.setChild(box)

  var group = newGroup("", true)
  box.add(group, false)

  var inner = newVerticalBox(true)
  group.child = inner

  inner.add(newButton("Start async proc", proc() =
    if doCount:
      return

    doCount = true
    asyncCheck asyncProc()
  ))

  inner.add(newButton("Stop async proc", proc() =
    doCount = false
    label.text = "Stopped counting"
  ))

  label = newLabel("Counter: ")
  inner.add(label)

  show(mainwin)
  pollingMainLoop(pollAsyncEvents, 10)

init()
main()
