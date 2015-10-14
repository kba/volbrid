% VOLBRI(1) volbrid user manual
% Konstantin Baierer
% October 10, 2015

# NAME

volbri - Change volume and brightness with notification

# SYNOPSIS

volbriosd <*backend*> <*cmd*> [*val*]

# DESCRIPTION

volbri is the command line interface to volbrid(1), a uniform interface to
external commands for setting the volume of an audio device and the brightness
of a display. In addition to changing the values, volbrid notifies the user
using a notification backendd

# EXAMPLES

Increase the volume by the default volume step:

```
volbri volume inc
```

Decrease the brightness by 50 %

```
volbri brightness dec 50
```

Toggle mute

```
volbri volume toggle
```

Set the brightness to 0 (or the lowest possible)

```
volbri brightness set 0
```


# SEE ALSO

xbacklight(1), notify-send(1), yad(1), pacmd(1), pactl(1)
