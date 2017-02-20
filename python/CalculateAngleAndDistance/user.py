import cv2
import numpy as np
import math

#Takes an image and returns an inverted blured (noise removed) binary image in its place
def biModalInvBlur(image):

	#turns all pixels that are darker than 60 -> 255, all others 0
	image1 = cv2.threshold(image, 60, 255, cv2.THRESH_BINARY_INV)
	
	height, width = image.shape
	
	#add border and blur to remove noise from image
	tempImg = cv2.copyMakeBorder(image1[1],5,5,5,5,cv2.BORDER_CONSTANT,value=(0,0,0,0))	
	tempImg = cv2.medianBlur(tempImg,7)
	
	#return bimodal image
	image = tempImg[5:5+height,5:width+5]
	return image
	

#Takes an image and returns the center of mass of the white central contour
#for this function to work the image must be binary, and the noise must be removed
#such that there is only one contour in the image
#centroid[0] is the x cooridnate
#centroid[1] is the y cooridnate
def centerMass(image):

	#find the moments of the image
	moments = cv2.moments(image,True)
	
	centroid = ( moments['m10']/moments['m00'],moments['m01']/moments['m00'] )
	

	return centroid
	
	
def undistortImg(image, intrinsicMatrix, distortionCoeffs, refinedCameraMatrix, ROI):
	
	# undistort
	undistortedImage = cv2.undistort(image, intrinsicMatrix, distortionCoeffs, None, refinedCameraMatrix)

	# crop the image
	x,y,w,h = ROI
	undistortedImage = undistortedImage[y:y+h, x:x+w]
		
	return undistortedImage
	
	
#alpha2angle takes in the number of pixels from the left edge of an undistorted image and returns how many radians that is from camA
#this works for LeftCam
def convert2Alpha(pixels):
        
        #each pixel is N deg in FOV
        #multiply the number of pixels by that conversion factor to get degress from the left
        #convert to radians

	degPerPixel = 0.574712
	#X is the angle of the left edge of the picture
	#X = 59.65
	X = 120.34
	#alpha = 20 / 33.9333333*pixels*-1
	alpha = degPerPixel*pixels
	#the left camera is mounted pivioted in X deg
	alpha = X - alpha
	print "DEBUG ALPHA DEG\n"
	print alpha
	return math.radians(alpha)

#this works for RightCam
def convert2Beta(pixels):

	degPerPixel = 0.515464
	#X is the angle of the left edge of the picture
	X = 25
	beta = degPerPixel*pixels
	#the right camera is mounted pivioted in X deg
	beta = X + beta
	print "DEBUG BETA DEG\n"
	print beta
	return math.radians(beta)
	
def calculateAngleAndDistance(leftImage, rightImage, leftCamera, rightCamera):
	#returned values are: 
	#	the distance for the center point of the robot to the object
	#	the angle for that same center point (negative is left)

	#Outline of steps
	#Load Intrisic Matricies
	#Load Distortion Coeficcients

	#Load Left Image
	##Make Image Bimodal
	##Undistort Image
	##Find center of mass
 
	#Load Right Image
	##Make Image Bimodal
	##Undistort Image
	##Find center of mass 

	#Use law of cosines to calculate distance

	bwImageLeft = biModalInvBlur(leftImage)
	uImageLeft = undistortImg(bwImageLeft, leftCamera['intrinsicMatrix'], leftCamera['distortionCoeffs'], leftCamera['refinedCameraMatrix'], leftCamera['roi'])
	centerLeft = centerMass(uImageLeft)
	
	bwImageRight = biModalInvBlur(rightImage)
	uImageRight = undistortImg(bwImageRight, rightCamera['intrinsicMatrix'], rightCamera['distortionCoeffs'], rightCamera['refinedCameraMatrix'], rightCamera['roi'])
	centerRight = centerMass(uImageRight)
	
	#these are radians from left and right
	alpha = convert2Alpha(centerLeft[0])
	print "DEBUG ALPHA\n"
	print alpha
	beta = convert2Beta(centerRight[0])
	print "DEBUG BETA\n"
	print beta
	
	returnObj = privateDistanceFcnLeft(alpha, beta)
	
	print "DEBUG one"
	print returnObj
	
	returnObj = privateDistanceFcnLeft(alpha+math.radians(10), beta-math.radians(10))
	
	print "DEBUG two"
	print returnObj
	
	returnObj = privateDistanceFcnLeft(alpha-math.radians(10), beta+math.radians(10))
	
	print "DEBUG three"
	print returnObj
	
	returnObj = privateDistanceFcnRight(alpha, beta)
	
	print "DEBUG one"
	print returnObj
	
	returnObj = privateDistanceFcnRight(alpha+math.radians(10), beta-math.radians(10))
	
	print "DEBUG two"
	print returnObj
	
	returnObj = privateDistanceFcnRight(alpha-math.radians(10), beta+math.radians(10))
	
	print "DEBUG three"
	print returnObj
	
	returnObj = privateDistanceFcnRight(alpha+math.radians(10), beta+math.radians(10))
	
	print "DEBUG four"
	print returnObj
	
	returnObj = privateDistanceFcnRight(alpha-math.radians(10), beta-math.radians(10))
	
	print "DEBUG five"
	print returnObj
	
	return returnObj
	
def privateDistanceFcnLeft(alpha, beta):
	S = (177.8 * math.sin(beta)) / (math.sin(math.pi - beta - alpha))
	objDistance = math.sqrt(7903.21 + (S*S) - (177.8 * S * math.cos(alpha)))
	tmpVar = S*math.sin(alpha)/objDistance
	print "JDHBETA"
	print tmpVar
	print "JDHBETA"
	angle1 = math.asin(88.9*math.sin(alpha)/objDistance)
	omega = math.pi - angle1 - alpha
	print "\n\n\n"
	print math.degrees(omega)
	print "\n\n\n"
	theta = (math.pi/2) - omega
	theta = math.degrees(theta)
	
	return (objDistance, theta)
	
def privateDistanceFcnRight(alpha, beta):
	S = (177.8 * math.sin(beta)) / (math.sin(math.pi - beta-alpha))
	objDistance = math.sqrt(7903.21 + (S*S) - (177.8 * S * math.cos(beta)))
	angle1 = math.asin(88.9*math.sin(beta)/objDistance)
	omega = math.pi - angle1 - beta
	theta = (math.pi/2) - omega
	theta = math.degrees(theta)
	
	return (objDistance, theta)

