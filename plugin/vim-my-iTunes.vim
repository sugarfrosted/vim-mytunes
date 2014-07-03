let g:iTunesPlayerActive = 0
let g:MyTunesScriptPath = expand('<sfile>:p')
python << endpython
def iTunesActive():
    try:
        from applescript import AppleScript
    except ImportError:
        return False
    else:
        return True
if iTunesActive():
    from applescript import AppleScript
    import applescript
    from re import match
    from re import UNICODE
    import os
    import vim
    vim.vars["iTunesPlayerActive"] = 1
    mytunespath = vim.vars["MyTunesScriptPath"]
    for repetitions in range(2):
        mytunespath = os.path.split(mytunespath)[0]#strips last path elements
    
    mute_file = os.path.join(mytunespath, 'mutestatus.pickle')
    if not os.path.isfile(mute_file) or os.stat(mute_file).st_size == 0:
        import pickle
        mute = open(mute_file,'w')
        pickle.dump(None, mute)
        mute.seek(0)
    mute = open(mute_file,'r+')    
    ascript = {\
       'get_Vol':AppleScript('tell application "itunes" to return sound volume'), \
       'set_Vol':AppleScript(\
           """on run {level}
                  tell application "itunes" to set sound volume to level
              end run"""),\
       'stop':AppleScript('tell application "itunes" to stop'),\
       'play':AppleScript('tell application "itunes" to playpause'),\
       'next':AppleScript('tell application "itunes" to next track'),\
       'previous':AppleScript('tell application "itunes" to previous track'), \
       'name':AppleScript('tell application "itunes" to return name of current track'),\
       'artist':AppleScript('tell application "itunes" to return artist of current track'),\
       'album':AppleScript('tell application "itunes" to return album of current track'),\
       'status':AppleScript('tell application "itunes" to return player state'),\
       'finish':AppleScript('tell application "itunes" to return finish of current track'),\
       'get_Pos':AppleScript('tell application "iTunes" to return player position'),\
       'set_Pos':AppleScript(\
           """on run {New_position}
                  tell application "itunes" to set player position to New_position
              end run""")}
    def track_time_float():
       if is_paused() or is_playing():
          return float(ascript["get_Pos"].run())
       else:
          return None
    def mute_iTunes():
        import pickle
        volLVL = ascript["get_Vol"].run()
        muteSTATS = pickle.load(mute)
        mute.seek(0)
        if muteSTATS is None:
            muteSTATS = ascript['get_Vol'].run()
            pickle.dump(muteSTATS, mute)
            mute.seek(0)
            ascript['set_Vol'].run(0)
            print "muted"
        else:
            ascript['set_Vol'].run(muteSTATS)
            muteSTATS = None
            pickle.dump(muteSTATS, mute)
            mute.seek(0)
            print "muted"

    def track_end_float():
        if is_paused() or is_playing():
            return float(ascript["finish"].run())
        else:
            return None
    def display_time():
        current = ascript["get_Pos"].run()
        finish =  ascript["finish"].run()
        
        output  =  timestamp_format(current)
        output += '/'
        output += timestamp_format(finish)
        return output


    def timestamp_format(seconds):
        seconds = int(round(seconds))
        m, s = divmod(seconds, 60)
        h, m = divmod(m, 60)
        if h >  0:
            #return "%d:%02d:%02d" % (h, m, s)
            return "{0:d}:{1:02d}:{2:02d}".format(h, m, s)
        elif s >= 0:
            #return "%d:%02d" % (m, s)
            return "{0:d}:{1:02d}".format(m, s)
        else:
            return "time is but an illusion"

    def position_delta(delta):
        current = track_time_float()
        finish  = track_end_float()

        new_position = timestamp_add(current, delta)
        if new_position is None or finish is None:
            print("iTunes is not playing or is playing a stream")
        elif new_position < 0:
            ascript["previous"].run()
        elif new_position > finish: 
            ascript["next"].run()
        else:
            ascript["set_Pos"].run(new_position)
        if is_playing():
            print("Currently Playing: " + currentTrackInfo())
        elif is_paused():
            print("Currently Paused on: " + currentTrackInfo())
    
    def is_paused():
        state = human_status()
        if state == "paused":
            return True
        else:
            try:
                ascript["name"].run()
            except applescript.ScriptError:
                return False
            else:
                return True

    def is_stopped():
        state = human_status()
        if state == "stopped":
            try:
                ascript["name"].run()
            except applescript.ScriptError:
                return True
            else:
                return False
        else:
            return False
    def is_playing():
        state = human_status()
        return state == "playing"

    def timestamp_add(a,b):
        if a is None or b is None: return None
        else: return a+b
        


    def human_status():
        status = str(ascript['status'].run())
        if match(r"AEEnum\('.{3}S'\)",status) is not None:
            return "stopped"
        elif match(r"AEEnum\('.{3}P'\)",status) is not None:
            return "playing"
        elif match(r"AEEnum\('.{3}p'\)",status) is not None:
            return "paused"
        else:
            return "OH GOD WHAT HAS SCIENCE DONE"
    def volume_delta(delta):
        current_level = int(ascript['get_Vol'].run())
        if current_level + delta < 0:
            volume_level = 0
        elif current_level + delta > 100:
            volume_level = 100
        else:
            volume_level = current_level + delta
            ascript['set_Vol'].run(volume_level)
    def itunes_stop():
        ascript['stop'].run()
        print("Playback Stopped")
    def itunes_play():
        ascript['play'].run()
        if is_playing():
            print("Currently Playing: " + currentTrackInfo())
        else:
            print("Currently Paused on: " + currentTrackInfo())
    def itunes_next():
        ascript['next'].run()
        if is_playing():
            print("Currently Playing: " + currentTrackInfo())
        elif is_paused():
            print("Currently Paused on: " + currentTrackInfo())
        elif is_stopped:
            print("iTunes is stopped")
    def itunes_prev():
        ascript['previous'].run()
        if is_playing():
            print("Currently Playing: " + currentTrackInfo())
        elif is_paused():
            print("Currently Paused on: " + currentTrackInfo())
        elif is_stopped():
            print("iTunes is stopped")
    def itunes_FF(amount):
        amount = int(amount)
        position_delta(amount)
        print(display_time())
    def itunes_RW(amount):
        amount = int(amount)
        position_delta(-amount)
        print(display_time())
    def itunes_volup():
        volume_delta(20)
        print("Current volume level:", str(currentVolumeLevel()) + "%")
    def itunes_voldown():
        volume_delta(-20)
        print("Current volume level:", str(currentVolumeLevel()) + "%")
    def currentTrackInfo():
        noText = r"^\s*$"
        track_name = ascript['name'].run()
        track_artist = ascript['artist'].run()
        if match(noText,track_artist):
            track_artist = "Unknown Artist"
        track_album = ascript['album'].run()
        if match(noText,track_album):
            track_album = "Unknown Album"

        output = track_name + " by " + track_artist + " from: " + track_album
        output += ' ' + display_time()
        return output
    def currentVolumeLevel():
        return ascript['get_Vol'].run()
    def itunes_getTrackName():
        if is_stopped():
            print("iTunes is Stopped")
        else:
            print("Current Track: " + currentTrackInfo())
endpython
function! MyTunesMaps(...)
    if len(a:000) >= 1
        let g:mytunesprefix = a:000[0]
    else
        if !exists('g:mytunesprefix')
            let g:mytunesprefix = ',t'
        endif
    endif
    let g:mytuneserror = 'Requirements Not Installed' "putting quotation will end poorly.
    if g:iTunesPlayerActive
        exe "noremap " . g:mytunesprefix . "s :py itunes_stop()<enter>"
        exe "noremap " . g:mytunesprefix . "p :py itunes_play()<enter>"
        exe "noremap " . g:mytunesprefix . "H :py itunes_prev()<enter>"
        exe "noremap " . g:mytunesprefix . "L :py itunes_next()<enter>"
        exe "noremap " . g:mytunesprefix . "k :py itunes_volup()<enter>"
        exe "noremap " . g:mytunesprefix . "j :py itunes_voldown()<enter>"
        exe "noremap " . g:mytunesprefix . "t :py itunes_getTrackName()<enter>"
        exe "noremap " . g:mytunesprefix . "l :py itunes_FF(10)<enter>"
        exe "noremap " . g:mytunesprefix . "h :py itunes_RW(10)<enter>"
        exe "noremap " . g:mytunesprefix . "3l :py itunes_FF(60)<enter>"
        exe "noremap " . g:mytunesprefix . "3h :py itunes_RW(60)<enter>"
        exe "noremap " . g:mytunesprefix . "6l :py itunes_FF(60)<enter>"
        exe "noremap " . g:mytunesprefix . "6h :py itunes_RW(60)<enter>"
        exe "noremap " . g:mytunesprefix . "66l :py itunes_FF(300)<enter>"
        exe "noremap " . g:mytunesprefix . "66h :py itunes_RW(300)<enter>"
    else
        exe "noremap " . g:mytunesprefix . "s :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "p :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "h :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "l :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "k :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "j :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "t :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "L :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "H :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "3l :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "3h :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "6l :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "6h :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "66l :echo '" . g:mytuneserror . "'<enter>"
        exe "noremap " . g:mytunesprefix . "66h :echo '" . g:mytuneserror . "'<enter>"
    endif
endfunction
call MyTunesMaps()
