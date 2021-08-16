Wesnoth ladder friends list synchronization
===========================================

This script lets you synchronize the ladder users to your wesnoth profile, so ladder players are highlighted in the multiplayer lobby.  
The resulting friends have an attached comment so they are distinguished from your manually set friends.


Usage
------------
From a terminal window, call: `wesnoth_ladder_friends.sh <mode> [preffile]`

- `mode`:      mode to operate in (mandatory parameter):
  - `add`:        add LoW members
  - `add-ladder`: add just the active ladder rated members from ladder page
  - `clean`:      clean LoW members from list
- `preffile`:   optional path to preferences file, otherwise 1.14 default location



Install / Prerequisites
-----------------------
The script relies on `wget` to fetch the ladder website data.  
If you have that, just clone the repo, make executable and call it.

You can for example run `wesnoth-ladder-friends.sh add-ladder` in your crontab or desktop autostart.
