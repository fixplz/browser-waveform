
$ ->
  canvas = $('#canvas')
  status = $('#status')

  sections = canvas.attr('width')

  view = WaveformView canvas

  req = new XMLHttpRequest()
  req.open 'GET', 'src.ogg', true
  req.responseType = 'arraybuffer'

  req.onprogress = (e) ->
   status.text "Loading file #{e.loaded/e.total*100}%"

  req.onload = ->
    ProcessAudio.extract req.response, sections, view.drawBar

  req.send()


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

  drawBar: (i,val) ->
    val *= 20
    ctx.fillRect(i,0,1,height*val)


ProcessAudio =
  extract: (src, sections, out, done) ->
    audio = new webkitAudioContext()
    buf = audio.createBuffer(src,true).getChannelData(0)

    len = Math.floor buf.length/sections
    i = 0

    f = ->
      pos = i*len
      out i, ProcessAudio.measure(pos,pos+len, buf)
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

