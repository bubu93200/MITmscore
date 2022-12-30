# =============================================================================
#   Midi Instrument Training plugin for MuseScore
#   Copyright (C) 2014 Jean-Baptiste Delisle
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License version 2
#   as published by the Free Software Foundation and appearing in
#   the file LICENCE.GPL
# =============================================================================

#!/bin/bash
qsynth &
sleep 1
aconnect -x
aconnect "$1" "FLUID Synth"
