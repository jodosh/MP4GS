import cv2
import numpy as np
import serial


loopCounter = 0
inByte = bytearray(4800) #4800 pixels in an 80x60 image each pixel is 8-bit
counterArr = bytearray(3)
ser = serial.Serial('/dev/ttyACM3', 115200, timeout=None)
isTrue = True


def setCounter():
  counterArr[0] = ser.read(1)
  counterArr[1] = ser.read(1)
  counterArr[2] = ser.read(1)
  
  counter = counterArr[0]+(counterArr[1]*256)+(counterArr[2]*65536)
  return counter


def getImage(fileName, counter):
    
	incomingCounter = 0
	while (incomingCounter < counter):
		inByte[incomingCounter] = ser.read(1)	 #save the int values for the HEX of each pixel
		incomingCounter+=1
	 
	
	
	image = np.mat(inByte)
	image = image.reshape(60,80)
	
	#Just for Testing
	cv2.imshow('img',image)
	cv2.waitKey(0)
	cv2.imwrite("8bitGrey.bmp", image)
	return image



while(isTrue):

	print("Press anykey to take a picture.")
	print("You have already captured %d images" % (loopCounter))
	ser.write("A") #write A out of serial port to let MP4GS know we are ready for a picture
	
	counter = setCounter()
  
	if (loopCounter < 10):
		image = getImage(("0%dLeft.bmp" % (loopCounter)), counter)
		isTrue = False
		cv2.destroyAllWindows()
		ser.close()
	else:
		image = getImage(("%dLeft.bmp" % loopCounter), counter)
		isTrue = False
		cv2.destroyAllWindows()
		ser.close()
  
    
