import numpy as np
import cv2
import glob

# termination criteria
criteria = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 100, .01)
goodImages = 0

# prepare object points, like (0,0,0), (1,0,0), (2,0,0) ....,(6,5,0)
objp = np.zeros((3*4,3), np.float32)
objp[:,:2] = np.mgrid[0:4,0:3].T.reshape(-1,2)

# Arrays to store object points and image points from all the images.
objpoints = [] # 3d point in real world space
imgpoints = [] # 2d points in image plane.

images = glob.glob('*Right.bmp')

for fname in images:
	print("Working on file: %s" % (fname))
	img = cv2.imread(fname,cv2.CV_LOAD_IMAGE_COLOR)
	gray = cv2.imread(fname,0)

    # Find the chess board corners
	ret, corners = cv2.findChessboardCorners(gray, (4,3),None)

    # If found, add object points, image points (after refining them)
	if ret == True:
		print("Found Corners for %s" % (fname))
				
		objpoints.append(objp)

		cv2.cornerSubPix(gray,corners,(5,5),(-1,-1),criteria)
		if corners is None:
			print("Something went wrong with cornerSubPix in file: %s" % (fname))
		else:
			imgpoints.append(corners)
			goodImages+=1

			# Draw and display the corners
			cv2.drawChessboardCorners(img, (4,3), corners,ret)
			cv2.imshow('img',img)
			cv2.waitKey(0)

			
			
if goodImages >9:			
	ret, intrinsicMatrix, distortionCoeffs, rvecs, tvecs = cv2.calibrateCamera(objpoints, imgpoints, gray.shape[::-1],None,None)

	h,  w = img.shape[:2]
	refinedCameraMatrix, roi=cv2.getOptimalNewCameraMatrix(intrinsicMatrix,distortionCoeffs,(w,h),1,(w,h))

	np.savez("refinedCameraMatrixRight", refinedCameraMatrix)
	np.savez("ROIRight", roi)
	np.savez("intrinsicMatrixRight", intrinsicMatrix)
	np.savez("distortionCoeffsRight", distortionCoeffs)
else:
	print("You need to supply at least 10 good images. You supplied %d" % (goodImages))	
	
cv2.destroyAllWindows()