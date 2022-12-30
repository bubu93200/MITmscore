//=============================================================================
//  Midi Instrument Training plugin for MuseScore
//  Copyright (C) 2014 Jean-Baptiste Delisle
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "lo/lo.h"

int main(int argc, char *argv[]) {
  lo_address mscore_osc = lo_address_new(NULL, "5282");
  lo_send(mscore_osc, "/actions/play", NULL);
  system("killall aplaymidi MIT");
}
