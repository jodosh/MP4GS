import cv2
import numpy as np
import serial
import user



leftCamera = np.load('LeftCamera.npz')
rightCamera = np.load('RightCamera.npz')

print (leftCamera['roi'])


img = cv2.imread('Left.bmp',0)

#cv2.imshow('image',img)
#cv2.waitKey(0)

#undistortImg(image, intrinsicMatrix, distortionCoeffs, refinedCameraMatrix, ROI)

img2 = user.undistortImg(img, leftCamera['intrinsicMatrix'], leftCamera['distortionCoeffs'], leftCamera['refinedCameraMatrix'], leftCamera['roi'])

cv2.imshow('image',img2)
cv2.waitKey(0)
cv2.imwrite("LeftUndistort.bmp", img2)




print (rightCamera['roi'])


img = cv2.imread('Right.bmp',0)

#cv2.imshow('image',img)
#cv2.waitKey(0)

#undistortImg(image, intrinsicMatrix, distortionCoeffs, refinedCameraMatrix, ROI)

img2 = user.undistortImg(img, rightCamera['intrinsicMatrix'], rightCamera['distortionCoeffs'], rightCamera['refinedCameraMatrix'], rightCamera['roi'])

cv2.imshow('image',img2)
cv2.waitKey(0)
cv2.imwrite("RightUndistort.bmp", img2)






cv2.destroyAllWindows()
leftCamera.close()
rightCamera.close()
