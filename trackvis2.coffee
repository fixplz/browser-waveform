
$ ->
  window.canvas = $('#canvas')
  loadFile 'src.ogg'


loadFile = (file) ->
  status = $('#status')

  sections = canvas.attr('width')

  view = WaveformView canvas

  req = new XMLHttpRequest()
  req.open 'GET', file, true
  req.responseType = 'arraybuffer'

  req.onprogress = (e) ->
   status.text "Loading file #{e.loaded/e.total*100}%"

  req.onload = -> loadBuffer req.response

  req.send()
  
  loadBuffer = (arr) ->
    audio = new webkitAudioContext()
    buf = audio.createBuffer(arr,true)
    
    ProcessAudio.extract(
      buf.getChannelData(0)
      sections, view.drawBar
    )
    
    play = PlayBuffer audio, buf
    view.onCursor = play.skip


WaveformView = (canvas) ->
  {width,height} = canvas[0]
  ctx = canvas[0].getContext('2d')
  ctx.fillStyle = 'black'

  cursor= $ """
    <div style="
      position: relative;
      height: #{height}px;
      width: 2px;
      background-color: blue;">
    """

  overlay = $ """
    <div style="
      position: relative;
      top: -#{height}px;
      height: 0px;">
    """

  overlay.append cursor
  canvas.after overlay

  canvas.click (e) ->
    mx = e.pageX-@offsetLeft
    cursor.css 'left', mx
    self.onCursor? mx/width

  self =
    drawBar: (i,val) ->
      val *= 20
      ctx.fillRect(i,0,1,height*val)


PlayBuffer = (audio,buffer) ->
  node = null
  start = (t) ->
    node = audio.createBufferSource()
    node.buffer = buffer
    node.connect audio.destination
    if t==0
      node.noteOn 0
    else
      node.noteGrainOn 0, t, buffer.duration-t
  
  start(0)
  
  skip: (t) ->
    node.noteOff 0
    start(t*buffer.duration)


ProcessAudio =
  extract: (buffer, sections, out, done) ->
    len = Math.floor buffer.length/sections
    i = 0

    f = ->
      pos = i*len
      out i, ProcessAudio.measure(pos,pos+len, buffer)
      i++
      if i >= sections
        clearInterval int
        done?()

    int = setInterval f, 1

  measure: (a,b, data) ->
    sum = 0.0
    for i in [a..b-1]
      s = data[i]
      sum += s*s
    Math.sqrt sum/data.length

