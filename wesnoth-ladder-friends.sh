#!/bin/bash
#
# Add Ladder of Wesnoth users to friend list (1.14 aquaintance format)
#
# Usage: wesnoth_ladder_friends.sh <mode> [preffile]
#
#  mode:     mode to operate in:
#            - "add":        add LoW members
#            - "add-ladder": add just the ladder rated members from ladder page
#            - "clean":      clean LoW members from list
#  preffile: optional path to preferences file
#
#
# License: GPLv3
#

# OpMode
MODE=""
[[ "$1" =~ ^add|add-ladder|clean$ ]] && MODE="$1"
[[ -z "$MODE" ]] && echo "mode '$1' invalid (expected: add|add-ladder|clean)!" && exit 1


# Path to Preferences file
PREFFILE=~/.config/wesnoth-1.14/preferences
[[ -n "$2" ]] && PREFFILE="$2"
[[ ! -w "$PREFFILE" ]] && echo "ERROR: preffile not writable: $PREFFILE" && exit 1



# Generate a "clean" preferences file: that is the file without LoW aquaintances
TMPFRIENDS=`mktemp /tmp/wesnoth.prefs.ori.XXXXXXXXXX`
A=2 B=2 match='notes="LoW"';
sed -ne:t -e"/\n.*$match/D" \
    -e'$!N;//D;/'"$match/{" \
            -e"s/\n/&/$A;t" \
            -e'$q;bt' -e\}  \
    -e's/\n/&/'"$B;tP"      \
    -e'$!bt' -e:P  -e'P;D'  ${PREFFILE} > ${TMPFRIENDS}


# Now add all the LoW as friends
TMPFILE=`mktemp /tmp/wesnoth.prefs.low-friends.XXXXXXXXXX`

if [[ $MODE == "add" ]]; then
        # Fetch ladder members from Web-API
        wget  -O${TMPFILE} "http://wesnoth.gamingladder.info/friends.php?download"
        [[ $? -gt 0 ]] && echo "ERROR fetching LoW friends list" && exit 1
        sed -i 's/friends=//' ${TMPFILE}
        sed -i 's/"//g' ${TMPFILE}
fi

if [[ $MODE == "add-ladder" ]]; then
        # Fetch ladder members from ladder table
        wget  -O${TMPFILE} "http://wesnoth.gamingladder.info/ladder.php"
        [[ $? -gt 0 ]] && echo "ERROR fetching LoW friends list" && exit 1

        TMPLADDERLIST=""
        for friend in $(cat ${TMPFILE} | grep -Eo "<a href=\"profile.php\?name=(.+?)\">(.+?)</a>" | sed 's/<a.\+>\(.\+\?\)<\/a.\+/\1/' |sed 's/^\s\+//'|sed 's/\s\+$//'); do
                [[ -n "$TMPLADDERLIST" ]] && TMPLADDERLIST="$TMPLADDERLIST,"
                TMPLADDERLIST="${TMPLADDERLIST}${friend}"
        done

        echo "$TMPLADDERLIST" > ${TMPFILE}
fi

# Add the fetched members
# TMPFILE is considered a file with a single comma separated list containing user names.
for friend in $(cat ${TMPFILE} | tr "," " "); do
        echo -e "[acquaintance]\n\tnick=\"${friend}\"\n\tnotes=\"LoW\"\n\tstatus=\"friend\"\n[/acquaintance]" >> ${TMPFRIENDS}
done


# Overwrite the old preference file
cp "${TMPFRIENDS}" "${PREFFILE}"

rm /tmp/wesnoth.prefs.*
