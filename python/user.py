import cv2
import numpy as np

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
	
	
def undistortImg(image, intrinsicMatrix, distortionCoeffs):
	print("one")
	
	#undistortMaps = cv2.initUndistortRectifyMap(intrinsicMatrix, distortionCoeffs, R, intrinsicMatrix, size, m1type[, map1[, map2]])
	
	#return undistortedImage
	
# void undistortImg(IplImage *imageA, CvMat *intrinsic, CvMat *distortion)
# {
	# IplImage* mapxA = cvCreateImage(cvGetSize(imageA), IPL_DEPTH_32F, 1);
	# IplImage* mapyA = cvCreateImage(cvGetSize(imageA), IPL_DEPTH_32F, 1);
	# cvInitUndistortMap(intrinsic, distortion, mapxA, mapyA);
	# IplImage *tA = cvCloneImage(imageA);
	# cvRemap(tA, imageA, mapxA, mapyA); // undistort image
	# cvReleaseImage(&tA);
# }