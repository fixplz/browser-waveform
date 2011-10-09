
@Waveform = ({file, canvas, onStatus,onReady}) ->
  canvas = $(canvas)
  status = $(status)

  sections = canvas.attr('width')

  view = WaveformView canvas

  req = new XMLHttpRequest()
  req.open 'GET', file, true
  req.responseType = 'arraybuffer'

  req.onprogress = (e) -> onStatus?(e.loaded/e.total)

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
    
    setInterval(
      -> view.moveCursor play.getTime()/buf.duration
      100
    )

    onReady?()

@WaveformView = (canvas) ->
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
    moveCursor: (pos) ->
      cursor.css 'left', pos*width


@PlayBuffer = (audio,buffer) ->
  node = null
  timeStart = null
  timeBasis = null
  
  start = (t) ->
    timeStart = Date.now()
    timeBasis = t
    
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
  getTime: ->
    Math.min(
      (Date.now()-timeStart)/1000 + timeBasis
      buffer.duration
    )


@ProcessAudio =
  extract: (buffer, sections, out, done) ->
    len = Math.floor buffer.length/sections
    i = 0

    f = ->
      end = i+10
      while i<end
        pos = i*len
        out i, ProcessAudio.measure(pos,pos+len, buffer)
        i++
        if i >= sections
          clearInterval int
          done?()
          break

    int = setInterval f, 1

  measure: (a,b, data) ->
    sum = 0.0
    for i in [a..b-1]
      s = data[i]
      sum += s*s
    Math.sqrt sum/data.length

