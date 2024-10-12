#!/usr/bin/env bash
#set -x

## Generic bemenu script. Will be run from other scripts to make sure, bemenu always looks the same

# colors
title_bg='#2ECC71' # green 
title_fg='#FDFEFE' # white
filter_bg='#FDFEFE' # white
filter_fg='#17202A' # black
cursor_bg='#2ECC71' # green
cursor_fg='#FDFEFE' # white
normal_bg='#FDFEFE' # white
normal_fg='#17202A' # black
hl_bg='#E74C3C' # red
hl_fg='#FDFEFE' # white
feedback_bg='#2874A6' # blue
feedback_fg='#FDFEFE' # white
sel_bg='#E74C3C' # red
sel_fg='#17202A' # black
alt_bg='#FDFEFE' # white
alt_fg='#17202A' # black
scroll_bg='#E74C3C' # red
scroll_fg='#FDFEFE' #white

# options
line_height=30
scrollbar=''

BEMENU_ARGS=(-n -i -w -p 'APPS' --tb "$title_bg" --tf "$title_fg" --fb "$filter_bg" --ff "$filter_fg" --cb "$cursor_bg" --cf "$cursor_fg" --nb "$normal_bg" --nf "$normal_fg" --hb "$hl_bg" --hf "$hl_fg" --fbb "$feedback_bg" --fbf "$feedback_fg" --sb "$sel_bg" --sf "$sel_fg" --ab "$alt_bg" --af "$alt_fg" --scb "$scroll_bg" --scf "$scroll_fg" --line-height 30 "$@")

if [ "$1" = 'dmenu' ]; then
  bemenu-run "${BEMENU_ARGS[@]}"
else
  bemenu "${BEMENU_ARGS[@]}"
fi
