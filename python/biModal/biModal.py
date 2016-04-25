import cv2
import numpy as np
import user

#make an image biModal


img = cv2.imread('Left.bmp',0)

img = user.biModalInvBlur(img)

cv2.imshow('image',img)
cv2.waitKey(0)
cv2.imwrite("LeftBiModal.bmp", img)

img = cv2.imread('Right.bmp',0)

img = user.biModalInvBlur(img)

cv2.imshow('image',img)
cv2.waitKey(0)
cv2.imwrite("RightBiModal.bmp", img)

cv2.destroyAllWindows()
