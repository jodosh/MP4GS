import cv2
import numpy as np
import serial


loopCounter = 0
inByte = bytearray(4800) #4800 pixels in an 80x60 image each pixel is 8-bit
counterArr = bytearray(3)
ser = serial.Serial('COM21', 115200, timeout=None)
isTrue = True


def setCounter():
  counterArr[0] = ser.read(1)
  counterArr[1] = ser.read(1)
  counterArr[2] = ser.read(1)
  
  counter = counterArr[0]+(counterArr[1]*256)+(counterArr[2]*65536)
  #print counter   #debugging
  return counter


def getImage(fileName, counter):
    
	incomingCounter = 0
	position = 0
	while (incomingCounter < counter):
		tempByte = ser.read(1)
		inByte[position] = ((ord(tempByte) & 0xC0 >> 6) * 85)	 #save the int values for the HEX of each pixel
		position+=1
		inByte[position] = ((ord(tempByte) & 0x30 >> 4) * 85)	 #save the int values for the HEX of each pixel
		position+=1
		inByte[position] = ((ord(tempByte) & 0x0C >> 2) * 85)	 #save the int values for the HEX of each pixel
		position+=1
		inByte[position] = ((ord(tempByte) & 0x03) * 85)	 #save the int values for the HEX of each pixel
		position+=1
		incomingCounter+=1
	 
	
	
	image = np.mat(inByte)
	image = image.reshape(60,80)
	
	#Just for Testing
	#cv2.imshow('img',image)
	#cv2.waitKey(1)
	cv2.imwrite(fileName, image)
	return image



while(isTrue):

	print("You have already captured %d images" % (loopCounter))
	s = raw_input('Press anykey to take a picture, press Q to quit\n')
	if s == "Q":
	  ser.write("Q") #write Q out of serial port to let MP4GS know we are done
	  cv2.destroyAllWindows()
	  ser.close()
	  isTrue = False
	else:
	  ser.write("A") #write A out of serial port to let MP4GS know we are ready for a picture
	
	  counter = setCounter()
  
	  if (loopCounter < 10):
		image = getImage(("0%dLeft.bmp" % (loopCounter)), counter)
	  else:
		image = getImage(("%dLeft.bmp" % loopCounter), counter)
		
	
	  counter = setCounter()
  
	  if (loopCounter < 10):
		image = getImage(("0%dRight.bmp" % (loopCounter)), counter)
		loopCounter += 1
	  else:
		image = getImage(("%dRight.bmp" % loopCounter), counter)
		loopCounter += 1
  
    
