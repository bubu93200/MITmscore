import sys
from musescore import *

score = Score()
part = Part()
score.append(part)

notes = [Note(val) for val in [60, 62, 64, 65, 67, 69, 71, 72]]
for note in notes:
  part.append(note)

m = Measure(0, TimeSignature('4/4'))
for note in part.notes():
  m.append(note)
part.append(m)

score.write('example.mid')
sys.exit(0)
