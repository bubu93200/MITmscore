//=============================================================================
//  Midi Instrument Training plugin for MuseScore
//  Copyright (C) 2014 Jean-Baptiste Delisle
//  Based on seqdemo.c by Matthias Nagorni
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <alsa/asoundlib.h>
#include "lo/lo.h"

#define MAX_LENGTH 50 // Max number of notes played simultaneously

int MAX_BADNESS; // Maximum of badness corresponding to score 0
// Respective weights of start/end timing in the badness computation
int WEIGHT_START; // Start weight
int WEIGHT_ENDP; // Positive end weight (player end note after score)
int WEIGHT_ENDN; // Negative end weight (player end note before score, for breath taking)

typedef struct {
  int length;
  int channel;
  int note[MAX_LENGTH];
  int start[MAX_LENGTH];
  int tick[MAX_LENGTH];
  int link[MAX_LENGTH];
  int lstart[MAX_LENGTH];
  int lend[MAX_LENGTH];
  int ltick[MAX_LENGTH];
} MIDItrack;

MIDItrack newMIDItrack(int channel) {
  MIDItrack track = { .length=0, .channel=channel };
  return track;
}

int tmsec() {
  return (1000*clock())/CLOCKS_PER_SEC;
}

void track_note_on(MIDItrack *track, MIDItrack *ref, int note, int t, int tick) {
  int n;
  // If the number of simultaneous notes is > MAX_LENGTH
  // New notes are ignored
  if (track->length < MAX_LENGTH) {
    // Save note in tables
    track->note[track->length] = note;
    track->start[track->length] = t;
    track->tick[track->length] = tick;
    track->link[track->length] = -1;
    track->lstart[track->length] = -1;
    track->lend[track->length] = -1;
    track->ltick[track->length] = -1;
    // Try to link note with ref notes
    for (n=0; n<ref->length; n++) {
      if (ref->link[n]==-1 && ref->note[n]==track->note[track->length]) {
        ref->link[n] = track->length;
        track->link[track->length] = n;
      }
    }
    track->length += 1;
  }
}

int track_note_off(MIDItrack *track, MIDItrack *ref, int note, int t, int is_inst, int *tick) {
  int n, badness;
  // badness = difference in timing between both tracks
  // badness = -1 if no linked notes
  // badness = -2 if linked track note not ended (badness will be determined later)
  badness = -1;
  // Find which note just ended
  for (n = 0; n<track->length; n++) {
    if (note == track->note[n]) {
      // Test if note is linked
      if (track->link[n]>-1) {
        // Test if linked note has ended
        if (track->lend[n]>-1) {
          // Compute badness
          badness = WEIGHT_START * abs(track->start[n]-track->lstart[n]);
          // is_inst = 1 if instrument
          // is_inst =-1 if score
          if (is_inst*(t - track->lend[n]) > 0) {
            // Instrument stopped after score
            badness += WEIGHT_ENDP * abs(t - track->lend[n]);
          } else {
            // Instrument stopped before score
            // Player may need to breath...
            badness += WEIGHT_ENDN * abs(t - track->lend[n]);
          }
        } else {
          // Send infos to linked ref note
          ref->lstart[track->link[n]] = track->start[n];
          ref->lend[track->link[n]] = t;
          ref->ltick[track->link[n]] = track->tick[n];
          badness = -2;
        }
      }
      // Return score tick
      if (is_inst==1) {
        *tick = track->ltick[n];
      } else {
        *tick = track->tick[n];
      }
      // Remove note from table
      track->length -= 1;
      track->note[n] = track->note[track->length];
      track->start[n] = track->start[track->length];
      track->tick[n] = track->tick[track->length];
      track->link[n] = track->link[track->length];
      track->lstart[n] = track->lstart[track->length];
      track->lend[n] = track->lend[track->length];
      track->ltick[n] = track->ltick[track->length];
      break;
    }
  }
  return badness;
}

char *getcolor(int badness) {
  switch ((10*badness)/MAX_BADNESS) {
  case 0: return "blue"; break;
  case 1: case 2: case 3: return "green"; break;
  case 4: case 5: case 6: return "yellow"; break;
  case 7: case 8: case 9: return "orange"; break;
  default: return "red"; break;
  }
}


snd_seq_t *open_seq(char *name) {

  snd_seq_t *seq_handle;
  int portid;

  if (snd_seq_open(&seq_handle, "default", SND_SEQ_OPEN_INPUT, 0) < 0) {
    fprintf(stderr, "Error opening ALSA sequencer.\n");
    exit(1);
  }
  snd_seq_set_client_name(seq_handle, name);
  // Open port 0 (track 1, score)
  if ((portid = snd_seq_create_simple_port(seq_handle, name,
                                           SND_SEQ_PORT_CAP_WRITE|SND_SEQ_PORT_CAP_SUBS_WRITE,
                                           SND_SEQ_PORT_TYPE_APPLICATION)) < 0) {
    fprintf(stderr, "Error creating sequencer port.\n");
    exit(1);
  }
  // Open port 1 (track 2, instrument)
  if ((portid = snd_seq_create_simple_port(seq_handle, name,
                                           SND_SEQ_PORT_CAP_WRITE|SND_SEQ_PORT_CAP_SUBS_WRITE,
                                           SND_SEQ_PORT_TYPE_APPLICATION)) < 0) {
    fprintf(stderr, "Error creating sequencer port.\n");
    exit(1);
  }
  return(seq_handle);
}

void midi_event(snd_seq_t *seq_handle, MIDItrack *track1, MIDItrack *track2, lo_address *mscore_osc) {

  snd_seq_event_t *ev;
  int time, tick, badness;

  do {
    time = tmsec();
    snd_seq_event_input(seq_handle, &ev);
    switch (ev->dest.port) {
    case 0:// Event on track1 (score)
      // Check if the event is a the desired channel
      if (ev->data.note.channel == track1->channel) {
        if ( (ev->type == SND_SEQ_EVENT_NOTEON && (ev->data.note.velocity == 0)) ||
             (ev->type == SND_SEQ_EVENT_NOTEOFF) ) {
          // NOTEOFF event
          badness = track_note_off(track1, track2, ev->data.note.note, time, -1, &tick);
          // If badness is already determined
          if (badness>-2) {
            if (badness == -1 || badness > MAX_BADNESS) { badness = MAX_BADNESS; }
            lo_send(*mscore_osc, "/color-note", "iis", tick, ev->data.note.note, getcolor(badness));
          }
        } else if (ev->type == SND_SEQ_EVENT_NOTEON) {
          // NOTEON event
          track_note_on(track1, track2, ev->data.note.note, time, ev->time.tick);
        }
      }
      break;
    case 1:// Event on track2 (instrument)
      // Check if the event is a the desired channel
      if (ev->data.note.channel == track2->channel) {
        if ( (ev->type == SND_SEQ_EVENT_NOTEON && (ev->data.note.velocity == 0)) ||
             (ev->type == SND_SEQ_EVENT_NOTEOFF) ) {
          // NOTEOFF event
          badness = track_note_off(track2, track1, ev->data.note.note, time, 1, &tick);
          // If played note exists in score and badness is already determined
          if (badness>-1) {
            if (badness > MAX_BADNESS) { badness = MAX_BADNESS; }
            lo_send(*mscore_osc, "/color-note", "iis", tick, ev->data.note.note, getcolor(badness));
          } else if (badness==-1) {
            badness = MAX_BADNESS;
          }
        } else if (ev->type == SND_SEQ_EVENT_NOTEON) {
          track_note_on(track2, track1, ev->data.note.note, time, 0);
        }
      }
    }
    snd_seq_free_event(ev);
  } while (snd_seq_event_input_pending(seq_handle, 0) > 0);
}

int main(int argc, char *argv[]) {

  snd_seq_t *seq;
  int npfd, status;
  struct pollfd *pfd;
  char cmd[100];
  pid_t pid;

  MIDItrack track_part = newMIDItrack(atoi(argv[4]));
  MIDItrack track_inst = newMIDItrack(atoi(argv[3]));

  lo_address mscore_osc = lo_address_new(NULL, "5282");

  MAX_BADNESS=atoi(argv[5]);
  WEIGHT_START=atoi(argv[6]);
  WEIGHT_ENDP=atoi(argv[7]);
  WEIGHT_ENDN=atoi(argv[8]);


  seq = open_seq("FloF Sequencer");
  npfd = snd_seq_poll_descriptors_count(seq, POLLIN);
  pfd = (struct pollfd *)alloca(npfd * sizeof(struct pollfd));
  snd_seq_poll_descriptors(seq, pfd, npfd, POLLIN);

  // Set connections to Sequencer
  sprintf(cmd,"aconnect \"%s\" \"FloF Sequencer\":1", argv[1]);
  system(cmd);
  // Start musescore playing
  lo_send(mscore_osc, "/actions/rewind", NULL);
  lo_send(mscore_osc, "/actions/play", NULL);
  // Start score reading
  pid = fork();
  if (pid == 0) {
    // I am the child process
    execlp("aplaymidi","aplaymidi",argv[2],"-p","FloF Sequencer:0",NULL);
  } else {
    // I am the parent process
    // Analyze score & instrument data -> color notes
    // At the end of score, wait for the player to end his last notes
    while ((waitpid(pid, &status, WNOHANG)==0) || (track_inst.length>0)) {
      if (poll(pfd, npfd, 1) > 0) {
        midi_event(seq,&track_part,&track_inst,&mscore_osc);
      }
    }
  }
}
