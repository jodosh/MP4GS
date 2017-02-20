import cv2
import numpy as np
import serial
import time
import user

inByte = bytearray(19200) #19200 pixels in an 160x120 image each pixel is 8-bit
counterArr = bytearray(3)
ser = serial.Serial('COM6', 115200, timeout=None)
#ser = serial.Serial('COM6', 14400, timeout=None)
isTrue = True
isSetUp = False


def setCounter():
  counterArr[0] = ser.read(1)
  counterArr[1] = ser.read(1)
  counterArr[2] = ser.read(1)
  
  counter = counterArr[0]+(counterArr[1]*256)+(counterArr[2]*65536)
  print counter   #debugging
  return counter


def getImage(fileName, counter):
    
	incomingCounter = 0
	position = 0
	while (incomingCounter < counter):
	  tempByte = ser.read(1)
	  inByte[position] = ((ord(tempByte) & 0xF0 >> 4) *17)	 #save the int values for the HEX of each pixel
	  position+=1
	  inByte[position] = (ord(tempByte) & 0x0F) * 17	 #save the int values for the HEX of each pixel
	  position+=1
	  incomingCounter+=1
	 
	
	
	image = np.mat(inByte)
	image = image.reshape(120,160)
	
	#Just for Testing
	#cv2.imshow('img',image)
	#cv2.waitKey(1)
	cv2.imwrite(fileName, image)
	return image


while (not isSetUp):
	
	#s=raw_input("Press any key to begin")
	print("DEBUG starting")
	ser.write("53".decode("hex"))
	isSetUp = True



s = raw_input('When ready, press any key to go, press Q to quit\n')
if s == "Q":
  ser.write(s.encode('ascii')) #write Q out of serial port to let MP4GS know we are done
  cv2.destroyAllWindows()
  ser.close()
  isTrue = False
else:
  s = "P"
  leftCamera = np.load('LeftCamera.npz')
  rightCamera = np.load('RightCamera.npz')
  ser.write(s.encode('ascii')) #write "P" out of serial port to let MP4GS know we are ready for a picture

  counter = setCounter()

  leftImage = getImage("Left.bmp", counter)


  counter = setCounter()

  rightImage = getImage("Right.bmp", counter)
  
  movementArray = user.calculateAngleAndDistance(leftImage, rightImage, leftCamera, rightCamera)
  
  if ( movementArray[1] > 27.5):
	s = "F"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > 22.5):
	s = "E"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > 17.5):
	s = "D"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > 12.5):
	s = "C"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > 7.5):
	s = "B"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > 2.5):
	s = "A"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] < 2.5 and movementArray[1] > -2.5):
	s = "S"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > -7.5): #5
	s = "a"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > -12.5):#10
	s = "b"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > -17.5):#15
	s = "c"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > -22.5):#20
	s = "d"
	ser.write(s.encode('ascii'))
  elif ( movementArray[1] > -27.5):#25
	s = "e"
	ser.write(s.encode('ascii'))
  else:
	s = "f"
	ser.write(s.encode('ascii'))
	
print "DEBUG Angle Chosen was"
print s
	
  
    
