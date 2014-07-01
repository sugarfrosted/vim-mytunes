To install with vim-pathogen just do the usual thing. (Clone into the bundle folder.)

Requires vim with python2.7 on MacOSX, because plot.

Also requires the module applescript, which can be found at: https://pypi.python.org/pypi/py-applescript/1.0.0

Setting variable `g:mytunesprefix` in the .vimrc file overrides the default prefix `,t` or if already started use the command `call MyTunesMaps('string')`

With the default prefix the mapped keys are:

| mapping | function          |
|:-------:|:----------------- |
| `,tp`   | Play/Pause        |
| `,ts`   | Stop              |
| `,tL`   | Next Song         |
| `,tH`   | Previous Song     |
| `,tt`   | Show Track Info   |
| `,tj`   | Volume Down(20)   |
| `,tk`   | Volume Up(20)     |
| `,tl`   | Skip forward 10s  |
| `,th`   | Skip backward 10s |
| `,t3l`  | Skip forward 30s  |
| `,t3h`  | Skip forward 30s  |
| `,t6l`  | Skip forward 1m   |
| `,t6h`  | Skip forward 1m   |
| `,t66l` | Skip forward 5m   |
| `,t66h` | Skip forward 5m   |
