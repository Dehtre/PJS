# -*- coding: utf-8 -*-
import pygame, random, time, sys, os
from pygame.locals import *

pygame.init()

window = pygame.display.set_mode((500, 400))
pygame.display.set_caption("Wspaniale kosci v.0.1")

background = pygame.Surface(window.get_size())
background = background.convert()

gamestate = 0 # 0-menu, 1-gra, 2-instrukcje
player = 1 # gracz

font1 = pygame.font.Font(os.path.join("data\KeiserSousa.TTF"),36)
font2 = pygame.font.Font(os.path.join("data\KeiserSousa.TTF"),52)
font3 = pygame.font.Font(os.path.join("data\KeiserSousa.TTF"),24)
font4 = pygame.font.Font(os.path.join("data\KeiserSousa.TTF"),16)
	
array_d = ['1.PNG', '2.PNG', '3.PNG', '4.PNG', '5.PNG', '6.PNG']
array_ds = ['1s.PNG', '2s.PNG', '3s.PNG', '4s.PNG', '5s.PNG', '6s.PNG']
array_posX = [60, 140, 220, 300, 380]

group1 = pygame.sprite.Group()
group2 = pygame.sprite.Group()
	
logo = pygame.image.load('data\logo.PNG').convert_alpha()
logo_s = pygame.image.load('data\logo_s.PNG').convert_alpha()

logonapis = font2.render("Wspania³e kosci", True, (0,0,0))
newgame = font3.render("Nowa gra", True, (0,0,0))
instructions = font3.render("Instrukcje", True, (0,0,0))
instructions2 = font2.render("Rzucaj kosæmi", True, (0,0,0))
instructions3 = font2.render("i wygrywaj", True, (0,0,0))
player1 = font3.render("Rzut gracza 1:", True, (0,0,0))
player2 = font3.render("Rzut gracza 2:", True, (0,0,0))
pl1 = font4.render("(Gracz 1)", True, (0,0,0))
pl2 = font4.render("(Gracz 2)", True, (0,0,0))
select = font3.render("Wybierz kosci do przerzucenia", True, (0,0,0))
loading = font1.render("Trwa turlanie...", True, (0,0,0))
throw1 = font3.render("Przerzuæ", True, (0,0,0))
throw2 = font3.render("Nie przerzucaj", True, (0,0,0))
back = font3.render("Powrót", True, (0,0,0))
exit = font3.render("Wyjscie", True, (0,0,0))
author = font4.render("by Pasek", True, (0,0,0))
ending = font1.render("Trwa ca³kowanie", True, (0,0,0))
ending2 = font1.render("po kostkach...", True, (0,0,0))
winner = font2.render("Wygrywa", True, (0,0,0))
pl1w = font2.render("Gracz 1!", True, (0,0,0))
pl2w = font2.render("Gracz 2!", True, (0,0,0))
fortwo = font4.render("Dla dwóch graczy", True, (0,0,0))

newgame_r = pygame.Rect(70, 160, 140, 25)
instructions_r = pygame.Rect(70, 210, 155, 25)
exit_r = pygame.Rect(70, 260, 105, 25)	
back_r = pygame.Rect(300, 300, 110, 25)
throw2_r = pygame.Rect(230, 160, 190, 25)
throw2_r2 = pygame.Rect(230, 300, 190, 25)

class Dice(pygame.sprite.Sprite):
	def __init__(self, no):
		pygame.sprite.Sprite.__init__(self)
		self.image = load_image(array_d[no-1], -1)
		screen = pygame.display.get_surface()
		self.area = screen.get_rect()	
		self.number = no
		self.clicked = False
		self.rect = (0,0,60,60)
		
	def setPos(self, x, y):
		self.rect = pygame.Rect(x, y, 60, 60)
		
	def position2(self, r):
		self.rect = r
		
	def getRect(self):
		return self.rect
		
	def update(self):
		if self.clicked:
			self.image = load_image(array_d[self.number-1], -1)
			self.clicked = False
		else:
			self.image = load_image(array_ds[self.number-1], -1)
			self.clicked = True
			
	def rerollable(self):
		return self.clicked
	
	def diceNo(self):
		return self.number

def input(events):
	global gamestate
	global player
	for event in events:
		if event.type == QUIT:
			sys.exit(0)
		elif event.type == pygame.KEYDOWN:
			if event.key == pygame.K_ESCAPE:
				sys.exit(0)
		elif gamestate == 0:
			mousePos = pygame.mouse.get_pos();
			if event.type == pygame.MOUSEBUTTONUP:
				if newgame_r.collidepoint(mousePos):
					gamestate = 1
					changeState()
				elif instructions_r.collidepoint(mousePos):
					gamestate = 2
					changeState()
				elif exit_r.collidepoint(mousePos):
					sys.exit(0)			
		elif gamestate == 1:
			mousePos = pygame.mouse.get_pos()
			if event.type == pygame.MOUSEBUTTONUP:
				if back_r.collidepoint(mousePos) and player == 0:
						player = 1
						gamestate = 0
						changeState()
				elif throw2_r.collidepoint(mousePos) and player == 1:
					what = 0
					for d in group1:
						if d.rerollable():
							temprect = d.getRect()
							d.kill()
							d1 = throw()
							group1.add(d1)
							d1.position2(temprect)
							what = 1
					if what == 1:
						throwing()
						player = 2
					else:
						player = 2
						throwing()
					background.fill((255,255,100))
					background.blit(select, (30, 170))
					background.blit(player1,(30, 20))
					group1.draw(background)
					for pos in array_posX:
						d = throw()
						d.setPos(pos, 220)
						group2.add(d)
					group2.draw(background)
					background.blit(throw2, (230, 300))
					window.blit(background, (0,0))
					pygame.display.update()
				elif throw2_r2.collidepoint(mousePos) and player == 2:
					what = 0
					for d in group2:
						if d.rerollable():
							temprect = d.getRect()
							d.kill()
							d1 = throw()
							group1.add(d1)
							d1.position2(temprect)
							what = 1
					if what == 1:
						throwing()
					endgame()
				elif player == 1:
					what = 0
					for d in group1:
						if d.getRect().collidepoint(mousePos):
							d.update()
					for d in group1:
						if d.rerollable():
							what = 1
					if what == 1:
						background.fill((255,255,100))
						background.blit(select, (30, 20))
						group1.draw(background)
						background.blit(throw1, (260, 160))
						window.blit(background, (0,0))
						pygame.display.update()
					else:
						background.fill((255,255,100))
						background.blit(select, (30, 20))
						group1.draw(background)
						background.blit(throw2, (230, 160))
						window.blit(background, (0,0))
						pygame.display.update()
				elif player == 2:
					what = 0
					for d in group2:
						if d.getRect().collidepoint(mousePos):
							d.update()
					for d in group2:
						if d.rerollable():
							what = 1
					if what == 1:
						background.fill((255,255,100))
						background.blit(select, (30, 170))
						background.blit(player1,(30, 20))
						group1.draw(background)
						group2.draw(background)
						background.blit(throw1, (260, 300))
						window.blit(background, (0,0))
						pygame.display.update()
					else:
						background.fill((255,255,100))
						background.blit(select, (30, 170))
						background.blit(player1,(30, 20))
						group1.draw(background)
						group2.draw(background)
						background.blit(throw2, (230, 300))
						window.blit(background, (0,0))
						pygame.display.update()
		elif gamestate == 2:
			mousePos = pygame.mouse.get_pos()
			if event.type == pygame.MOUSEBUTTONUP:
				if back_r.collidepoint(mousePos):
					gamestate = 0
					changeState()

def endgame():
	global player
	background.fill((255,255,100))
	background.blit(player1,(30, 20))
	group1.draw(background)
	group2.draw(background)
	background.blit(player2, (30, 170))
	background.blit(ending, (40, 300))
	background.blit(ending2, (45, 335))
	window.blit(background, (0,0))
	pygame.display.update()
	pygame.time.wait(4000)
	player = 0
	background.fill((255,255,100))
	background.blit(back, (300, 300))
	background.blit(winner, (100, 100))
	if wins():
		background.blit(pl1w, (120, 150))
	else:
		background.blit(pl2w, (120, 150))
	window.blit(background, (0,0))
	pygame.display.update()

def changeState():
	if gamestate == 0:
		background.fill((255,255,100))
		background.blit(logonapis, (10, 15))
		background.blit(newgame, (70, 160))
		background.blit(fortwo, (290, 75))
		background.blit(instructions, (70, 210))
		background.blit(exit, (70, 260))
		background.blit(logo_s, (250, 200))
		window.blit(background, (0,0))
		pygame.display.update()
	elif gamestate == 1:
		throwing()
		background.fill((255,255,100))
		background.blit(select, (30, 20))
		for pos in array_posX:
			d = throw()
			d.setPos(pos, 80)
			group1.add(d)
		group1.draw(background)
		background.blit(throw2, (230, 160))
		window.blit(background, (0,0))
		pygame.display.update()
	elif gamestate == 2:
		background.fill((255,255,100))
		background.blit(instructions2, (30, 130))
		background.blit(instructions3, (30, 180))
		background.blit(back, (300, 300))
		window.blit(background, (0,0))
		pygame.display.update()

def throwing():
	background.fill((255,255,100))
	background.blit(loading, (80, 150))
	if player == 1:
		background.blit(pl1, (140, 190))
	else:
		background.blit(pl2, (140, 190))
	window.blit(background, (0,0))
	pygame.display.update()
	pygame.time.wait(2000)
		
def throw():
	return Dice(random.randint(1,6))
	
def reroll():
	for d in group1:
		if d.rerollable():
			temprect = d.getRect()
			d.kill()
			d1 = throw()
			group1.add(d1)
			d1.position2(temprect)
			
def wins():
	sum1 = 0
	sum2 = 0
	for d in group1:
		sum1 += d.diceNo()
	for d in group2: 
		sum2 += d.diceNo()
	if sum1 > sum2: 
		return True
	else:
		return False

def load_image(name, colorkey=None):
    fullname = os.path.join('data', name)
    try:
        image = pygame.image.load(fullname)
    except pygame.error, message:
        print 'Cannot load image:', name
        raise SystemExit, message
    image = image.convert()
    if colorkey is not None:
        if colorkey is -1:
            colorkey = image.get_at((0,0))
        image.set_colorkey(colorkey, RLEACCEL)
    return image
	
background.fill((255,255,100))
background.blit(logonapis, (10, 15))
background.blit(logo, (10,75))
background.blit(author, (405, 375))
background.blit(fortwo, (290, 75))
window.blit(background, (0,0))
pygame.display.update()
pygame.time.delay(5000)
changeState()

while True:
	input(pygame.event.get())