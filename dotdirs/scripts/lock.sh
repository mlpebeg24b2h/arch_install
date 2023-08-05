#!/usr/bin/env bash

## Lockscreen script
## Lockicon downloaded from https://creazilla.com/nodes/58783-locked-emoji-clipart
## No modifications were made on the lockicon
## Lockicon License: https://creativecommons.org/licenses/by/4.0/

PIC="~/Pictures/locked.jpg"

swaylock --daemonize \
  --image "$RANDOMPIC" \
  --scaling stretch \
  --indicator-idle-visible \
  --indicator-radius 150 \
  --indicator-thickness 12 \
  --ring-color 2E3440 \
  --key-hl-color ECEFF4 \
  --line-color 88C0D0 \
  --inside-color 00000040 \
  --separator-color 00000000 \
  --text-color ECEFF4 \
  --text-caps-lock-color ECEFF4 \
  --show-failed-attempts
