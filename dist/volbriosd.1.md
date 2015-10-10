% VOLBRIOSD(1) volbriosd user manual
% Konstantin Baierer
% October 10, 2015

# NAME

volbriosd - Change volume and brightness with notification

# SYNOPSIS

volbriosd <*backend*> <*cmd*> [*val*]

# DESCRIPTION

volbriosd is a uniform interface to external commands for setting the volume of
an audio device and the brightness of a display. In addition to changing the
values, volbriosd notifies the user using a notification backendd

# EXAMPLES

Increase the volume by the default volume step:

```
volbriosd volume inc
```

Decrease the brightness by 50 %

```
volbriosd brightness dec 50
```

Toggle mute

```
volbriosd volume toggle_mute
```

Set the brightness to 0 (or the lowest possible)

```
volbriosd brightness set 0
```


# SEE ALSO

xbacklight(1), notify-send(1), yad(1), pacmd(1), pactl(1)
