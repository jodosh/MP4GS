import cv2
import numpy as np
import serial
import user.py


loopCounter = 0
inByte = bytearray(4800) #4800 pixels in an 80x60 image each pixel is 8-bit
counterArr = bytearray(3)
ser = serial.Serial('/dev/ttyACM0', 115200, timeout=None)
isTrue = True


def setCounter():
  counterArr[0] = ser.read(1)
  counterArr[1] = ser.read(1)
  counterArr[2] = ser.read(1)
  
  counter = counterArr[0]+(counterArr[1]*256)+(counterArr[2]*65536)
  return counter


def getImage(counter):
    
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
	image = image.reshape(60,80)
	
	#Just for Testing
	#cv2.imshow('img',image)
	#cv2.imwrite(fileName, image)
	return image



while(isTrue):

	ser.write("A") #write A out of serial port to let MP4GS know we are ready for a picture
	
	counter = setCounter()
	leftImage = getImage(counter)
	counter = setCounter()
	rightImage = getImage(counter)
	
	calculateAngleAndDistance(leftImage, rightImage, intrinsicMatrixL, distortionCoeffsL, refinedCameraMatrixL, ROIL, intrinsicMatrixR, distortionCoeffsR, refinedCameraMatrixR, ROIR)