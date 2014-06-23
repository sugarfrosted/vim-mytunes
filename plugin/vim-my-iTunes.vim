thon << endpython

import os
def itunes_stop():
    os.system("""osascript -e 'tell application "itunes" to stop'""")
def itunes_play():
    os.system("""osascript -e 'tell application "itunes" to play'""")
    
def itunes_next():
    os.system("""osascript -e 'tell application "itunes" to next track'""")
def itunes_prev():
    os.system("""osascript -e 'tell application "itunes" to previous track'""")
endpython

map ,xs :py itunes_stop()<enter>
map ,xp :py itunes_play()<enter>
map ,x, :py itunes_prev()<enter>
map ,x. :py itunes_next()<enter>
