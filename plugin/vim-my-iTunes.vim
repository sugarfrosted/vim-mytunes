python << endpython
from subprocess import check_output
def volume_delta(delta):
    current_level = int(check_output("""osascript -e 'tell application "itunes" to return sound volume'""", shell=True))
    if current_level + delta < 0:
        volume_level = 0
    elif current_level + delta > 100:
        volume_level = 100
    else:
        volume_level = current_level + delta
    volume_level = str(volume_level)
    check_output("""osascript -e 'tell application "itunes" to set sound volume to """ + volume_level + "'", shell=True)
def itunes_stop():
    check_output("""osascript -e 'tell application "itunes" to stop'""", shell=True)
def itunes_play():
    check_output("""osascript -e 'tell application "itunes" to playpause'""", shell=True)
    if "playing\n" == check_output("""osascript -e 'tell application "itunes" to return player state'""", shell=True):
        print "Currently Playing: " + currentTrackName()
    else:
        print "Currently Paused on: " + currentTrackName()
def itunes_next():
    check_output("""osascript -e 'tell application "itunes" to next track'""", shell=True)
def itunes_prev():
    check_output("""osascript -e 'tell application "itunes" to previous track'""", shell=True)
def itunes_volup():
    volume_delta(20)
def itunes_voldown():
    volume_delta(-20)
def currentTrackName():
    track_name = check_output("""osascript -e 'tell application "itunes" to return the name of current track'""", shell=True)
    track_artist = check_output("""osascript -e 'tell application "itunes" to return the artist of current track'""", shell=True)
    track_album = check_output("""osascript -e 'tell application "itunes" to return the album of current track'""", shell=True)
    output = track_name + " by " + track_artist + " on the album: " + track_album
    return ''.join(output.splitlines())
def itunes_getTrackName():
    if "stopped\n" == check_output("""osascript -e 'tell application "itunes" to return player state'""", shell=True):
        print "iTunes is Stopped"
    else:
        print "Current Track: " + currentTrackName()
endpython

noremap ,xs :py itunes_stop()<enter>
noremap ,xp :py itunes_play()<enter>
noremap ,xh :py itunes_prev()<enter>
noremap ,xl :py itunes_next()<enter>
noremap ,xj :py itunes_volup()<enter>
noremap ,xk :py itunes_next()<enter>
noremap ,xt :py itunes_getTrackName()<enter>
