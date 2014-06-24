python << endpython
from applescript import AppleScript
from re import match
ascript = {'get_Vol':AppleScript('tell application "itunes" to return sound volume'), \
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
           'status':AppleScript('tell application "itunes" to return player state')}

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
    print "Playback Stopped"
def itunes_play():
    ascript['play'].run()
    if "playing" == ascript['status'].run():
        print "Currently Playing: " + currentTrackInfo()
    else:
        print "Currently Paused on: " + currentTrackInfo()
def itunes_next():
    ascript['next'].run()
    if "playing" == human_status():
        print "Currently Playing: " + currentTrackInfo()
    elif "paused" == human_status():
        print "Currently Paused on: " + currentTrackInfo()
    elif "stopped" == human_status():
        print "iTunes is stopped"
def itunes_prev():
    ascript['previous'].run()
    if "playing" == human_status():
        print "Currently Playing: " + currentTrackInfo()
    elif "paused" == human_status():
        print "Currently Paused on: " + currentTrackInfo()
    elif "stopped" == human_status():
        print "iTunes is stopped"
def itunes_volup():
    volume_delta(20)
    print "Current volume level: ", currentVolumeLevel() + "%"
def itunes_voldown():
    volume_delta(-20)
    print "Current volume level: ", currentVolumeLevel() + "%"
def currentTrackInfo():
    track_name = ascript['name'].run()
    track_artist = ascript['artist'].run()
    track_album = ascript['album'].run()
    output = track_name + " by " + track_artist + " on the album: " + track_album
    return output
def currentVolumeLevel():
    return ascript['get_Vol'].run()
def itunes_getTrackName():
    if "stopped" == human_status():
        print "iTunes is Stopped"
    else:
        print "Current Track: " + currentTrackInfo()
endpython

noremap ,ts :py itunes_stop()<enter>
noremap ,tp :py itunes_play()<enter>
noremap ,th :py itunes_prev()<enter>
noremap ,tl :py itunes_next()<enter>
noremap ,tk :py itunes_volup()<enter>
noremap ,tj :py itunes_voldown()<enter>
noremap ,tt :py itunes_getTrackName()<enter>
