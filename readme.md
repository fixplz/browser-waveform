Experiment to get client-side waveform rendering of an audio track.

http://fixplz.blourp.com/wavevis/waveform.html

Currently works in Chrome through the 'webkitAudioContext' object.

Firefox only has their own useless nonstandard sound API thing that makes Flash look good.

----

Remember to run Chrome locally with --allow-file-access-from-files.

----

    Waveform :: ({file, canvas, onStatus, onReady}) -> {
      playback :: { moveCursor :: (Num) -> () }
      view :: {
        play     :: -> ()
        playAt   :: (Num) -> ()
        getTime  :: -> Num
        pause    :: -> ()
        isPaused :: -> Bool
      }
    }
