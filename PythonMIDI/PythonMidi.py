"""
 Python MIDI Graphic Running Program
 By Wilson Chao, May 2021.
 October 2021 remark 
 For rtmidi package, you need to install python-rtmidi  
"""
import pygame
import mido
import rtmidi
pygame.init()
BLACK = [  0,   0,   0]
WHITE = [255, 255, 255]
note_list = []
note_list_off = []
outport=mido.open_output()
inport=mido.open_input()
SIZE = [380, 380]
screen = pygame.display.set_mode(SIZE)
pygame.display.set_caption("Python MIDI Program by Wilson Chao")
clock = pygame.time.Clock()
done = False
while done == False:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            done=True
    for msg in inport.iter_pending():
        n = msg.note
        x=(n-47)*10 
        if msg.velocity)0:
           note_list.append([x, 0])
        else:       
           note_list_off.append([x, 0])           
    for i in range(len(note_list)):
        pygame.draw.circle(screen, WHITE, note_list[i], 10)
        note_list[i][1] += 1
    pygame.display.flip()
    for i in range(len(note_list_off)):
        pygame.draw.circle(screen, BLACK, note_list_off[i], 10)
        note_list_off[i][1] += 1   
    clock.tick(200)
pygame.quit ()
