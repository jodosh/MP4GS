import cv2
import numpy as np
import user

#takes the images in and bit depth, makes them biModal and return array wioth distance in mm and angle from center. (-angle denotes left of center)


leftImage = cv2.imread('Left.bmp',0)

rightImage = cv2.imread('Right.bmp',0)

leftCamera = np.load('LeftCamera.npz')
rightCamera = np.load('RightCamera.npz')



movementArray = user.calculateAngleAndDistance(leftImage, rightImage, leftCamera, rightCamera)




print movementArray






