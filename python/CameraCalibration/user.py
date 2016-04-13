import cv2
import numpy as np
import math

#Takes an image and returns an inverted blured binary image in its place
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
	
def deg2rad(deg):

	deg = 3.14159265*deg / 180
	return deg
	
#alpha2angle takes in the number of pixels from the left edge of an undistorted image and returns how many radians that is from camA
#this works for LeftCam
def alpha2angle(pixels):

	alpha = 20 / 33.9333333*pixels*-1
	alpha = alpha + 135 - 18
	return deg2rad(alpha)

#this works for RightCam
def beta2angle(pixels)

	beta = 20 / 31.125*pixels*-1
	beta = beta + 130.6747 + 15
	return deg2rad(beta)
	
def calculateAngleAndDistance(leftImage, rightImage, intrinsicMatrixL, distortionCoeffsL, refinedCameraMatrixL, ROIL, intrinsicMatrixR, distortionCoeffsR, refinedCameraMatrixR, ROIR):

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
	uImageLeft = undistortImg(bwImageLeft, intrinsicMatrixL, distortionCoeffsL, refinedCameraMatrixL, ROIL)
	centerLeft = centerMass(uImageLeft)
	
	bwImageRight = biModalInvBlur(rightImage)
	uImageRight = undistortImg(bwImageRight, intrinsicMatrixR, distortionCoeffsR, refinedCameraMatrixR, ROIR)
	centerRight = centerMass(uImageRight)
	
	#these are radians from left and right
	alpha = convert2Alpha(centerLeft[0])
	beta = convert2Beta(centerRight[0])
	
	#law of cosines to find the angle
	Y = (177 * math.sin(beta)) / (math.sin(180 - beta - alpha))
	#print("Y = %.2f \n", Y);
	objDistance = sqrt((8649 + pow(Y, 2)) - (186 * Y*math.cos(alpha)))
	theta = asin((Y*math.sin(alpha)) / (objDistance))
	theta = theta * 180 / 3.14159265
	theta = theta - 90
	
	return (objDistance, theta)

	
