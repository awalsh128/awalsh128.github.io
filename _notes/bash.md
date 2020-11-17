---
title: Bash Notes
date: '2020-11-13T00:00:00.000-07:00'
tags:
- git
modified_time: '2020-11-13T00:00:00.000-07:00'
excerpt: "Bash notes giving commonly used commands and some handy special workflows."
toc: true
---

## Beep Music

Github repositories with beep codes for songs:
* [Shane McC](https://github.com/ShaneMcC/beeps)
* [Joesf Friedrich](https://github.com/Josef-Friedrich/beep-melodies)

Example

```bash
#!/bin/bash

beep -f 330 -l 150 -n -f 1 -l 40 -n -f 494 -l 159 -n -f 1 -l 40 -n -f 660 -l 150 -n -f 1 -l 40 -n -f 590 -l 150 -n -f 660 -l 150 -n -f 494 -l 100 -n -f 494 -l 100 -n -f 523 -l 150 -n -f 1 -l 40 -n -f 440 -l 150 -n -f 1 -l 40 -n -f 494 -l 150 -n -f 1 -l 40 -n -f 392 -l 100 -n -f 392 -l 100 -n -f 440 -l 150 -n -f 370 -l 150 -n -f 1 -l 40 -n -f 392 -l 150 -n -f 1 -l 40 -n -f 330 -l 100 -n -f 330 -l 100 -n -f 370 -l 150 -n -f 1 -l 40 -n -f 294 -l 150 -n -f 1 -l 40 -n -f 330 -l 150 -n -f 247 -l 100 -n -f 247 -l 100 -n -f 261 -l 150 -n -f 1 -l 40 -n -f 311 -l 150 -n -f 1 -l 40 -n -f 330 -l 150 -n -f 1 -l 40 -n -f 247 -l 100 -n -f 247 -l 100 -n -f 262 -l 150 -n -f 1 -l 40 -n -f 370 -l 150 -n -f 1 -l 40 -n -f 330 -l 150 -n -f 1 -l 40 -n -f 494 -l 159 -n -f 1 -l 40 -n -f 660 -l 150 -n -f 1 -l 40 -n -f 590 -l 150 -n -f 660 -l 150 -n -f 494 -l 100 -n -f 494 -l 100 -n -f 523 -l 150 -n -f 1 -l 40 -n -f 440 -l 150 -n -f 1 -l 40 -n -f 494 -l 150 -n -f 1 -l 40 -n -f 392 -l 100 -n -f 392 -l 100 -n -f 440 -l 150 -n -f 370 -l 150 -n -f 1 -l 40 -n -f 392 -l 150 -n -f 1 -l 40 -n -f 330 -l 100 -n -f 330 -l 100 -n -f 370 -l 150 -n -f 1 -l 40 -n -f 294 -l 150 -n -f 1 -l 40 -n -f 330 -l 150 -n -f 247 -l 100 -n -f 247 -l 100 -n -f 261 -l 150 -n -f 1 -l 40 -n -f 311 -l 150 -n -f 1 -l 40 -n -f 330 -l 150 -n -f 1 -l 40 -n -f 247 -l 100 -n -f 247 -l 100 -n -f 262 -l 150 -n -f 1 -l 40 -n -f 370 -l 150 -n -f 1 -l 40 -n -f 330 -l 150 -n -f 1 -l 40

```

## Find &amp; Replace

```bash
#!/bin/bash

FILE=$1
FIND=$2
REPLACE=$3

ESCAPED_FIND=$(printf '%s\n' "$FIND" | sed -e 's/[]\/$*.^[]/\\&/g');
ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[\/&]/\\&/g');

sed -i -e "s/$ESCAPED_FIND/$ESCAPED_REPLACE/g" $FILE
```

## Wifi Monitor &amp; Auto Reconnect

```bash
#!/bin/bash

script_basename=`basename "$0"`

function beep_failure {
  beep -l 350 -f 392 -D 100 -n -l 350 -f 392 -D 100 -n -l 350 -f 392 -D 100
}

function log {
  echo "$(date): $1"
}

function log_with_file {
  log $1
  log $1 >> /tmp/$basename.err
}


while ! [ `read -t 15 -p "$(date): Hit any key in 15 seconds to exit."` ]; do
  echo ""
  if ! [ "$(ping -c 1 google.com)" ]; then
    beep_failure
    log_with_file "Detected ping failures against google.com. Resetting wifi and reconnecting to home AP."
    nmcli radio wifi off && sleep 5 && nmcli radio wifi on && sleep 5
    nmcli d wifi connect MyAccessPoint password mypassword
    log_with_file "Wifi reset and AP reconnected."
  else
    log "Able to ping google.com. No action taken."
  fi
done
```


## Resources

* [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
