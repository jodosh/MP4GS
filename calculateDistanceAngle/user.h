

CvHistogram* calcHistogram(IplImage *image, CvHistogram *hist)
{

	IplImage* imgRed = cvCreateImage(cvGetSize(image), 8, 1);
	IplImage* imgGreen = cvCreateImage(cvGetSize(image), 8, 1);
	IplImage* imgBlue = cvCreateImage(cvGetSize(image), 8, 1);

	cvSplit(image, imgBlue, imgGreen, imgRed, NULL);


	cvCalcHist(&imgRed, hist, 0, 0);
	return hist;
}

IplImage* DrawHistogram(CvHistogram *hist)
{
	float scaleX = 1;
	float scaleY = 1;
	float histMax = 0;
	cvGetMinMaxHistValue(hist, 0, &histMax, 0, 0);
	IplImage* imgHist = cvCreateImage(cvSize(256 * scaleX, 64 * scaleY), 8, 1);
	cvZero(imgHist);
	for (int i = 0; i<255; i++)
	{
		float histValue = cvQueryHistValue_1D(hist, i);
		float nextValue = cvQueryHistValue_1D(hist, i + 1);

		CvPoint pt1 = cvPoint(i*scaleX, 64 * scaleY);
		CvPoint pt2 = cvPoint(i*scaleX + scaleX, 64 * scaleY);
		CvPoint pt3 = cvPoint(i*scaleX + scaleX, (64 - nextValue * 64 / histMax)*scaleY);
		CvPoint pt4 = cvPoint(i*scaleX, (64 - histValue * 64 / histMax)*scaleY);

		int numPts = 5;
		CvPoint pts[] = { pt1, pt2, pt3, pt4, pt1 };

		cvFillConvexPoly(imgHist, pts, numPts, cvScalar(255));
	}
	return imgHist;
}

IplImage* singleCh(IplImage *img)
{
	IplImage* imgRed = cvCreateImage(cvGetSize(img), 8, 1);
	IplImage* imgGreen = cvCreateImage(cvGetSize(img), 8, 1);
	IplImage* imgBlue = cvCreateImage(cvGetSize(img), 8, 1);

	cvSplit(img, imgBlue, imgGreen, imgRed, NULL);

	cvReleaseImage(&imgBlue);
	cvReleaseImage(&imgGreen);
	return imgRed;
}

void biModal(IplImage *img)
{
	//Takes an image and returns a binary image in its place
	cvThreshold(img, img, 60, 255, CV_THRESH_BINARY_INV); //the assumption is that the can is almost tatally black


	//deal with any border shadows
	IplImage *img2 = cvCreateImage(cvSize(img->width + 10, img->height + 10), img->depth, img->nChannels);
	cvCopyMakeBorder(img, img2, cvPoint(5, 5), IPL_BORDER_CONSTANT, cvScalarAll(0));
	cvSmooth(img2, img2, CV_MEDIAN, 7, 3, 0);

	cvSetImageROI(img2, cvRect(5, 5, 128, 96));

	cvCopy(img2, img, NULL);
	cvReleaseImage(&img2);
}

void invert(IplImage *img)
{
	//invert Binary Image
	cvThreshold(img, img, 128, 255, CV_THRESH_OTSU && CV_THRESH_BINARY_INV);
}

CvPoint centerMass(IplImage *img)
{
	//Take a binary image and returns the center of mass of all the black pixels
	CvMoments *moments = (CvMoments*)malloc(sizeof(CvMoments));
	cvMoments(img, moments, 1);
	double moment10 = cvGetSpatialMoment(moments, 1, 0);
	double moment01 = cvGetSpatialMoment(moments, 0, 1);
	double area = cvGetCentralMoment(moments, 0, 0);

	int posX = moment10 / area;
	int posY = moment01 / area;

	return cvPoint(posX, posY);
}

void undistortImg(IplImage *imageA, CvMat *intrinsic, CvMat *distortion)
{
	IplImage* mapxA = cvCreateImage(cvGetSize(imageA), IPL_DEPTH_32F, 1);
	IplImage* mapyA = cvCreateImage(cvGetSize(imageA), IPL_DEPTH_32F, 1);
	cvInitUndistortMap(intrinsic, distortion, mapxA, mapyA);
	IplImage *tA = cvCloneImage(imageA);
	cvRemap(tA, imageA, mapxA, mapyA); // undistort image
	cvReleaseImage(&tA);
}

//alpha2angle takes in the number of pixels from the left edge of an undistorted image and returns how many degrees that is from camA
float alpha2angle(float alpha)
{
	alpha = 20 / 33.9333333*alpha*-1;
	alpha = alpha + 135 - 18;
	return alpha;
}

float beta2angle(float beta)
{
	beta = 20 / 31.125*beta*-1;
	beta = beta + 130.6747 + 15;
	return beta;
}

float deg2rad(float deg)
{
	deg = 3.14159265*deg / 180;
	return deg;
}

float rad2deg(float rad)
{
	rad = rad * 180 / 3.14159265;
	return rad;
}


/*void stereoUndistortRectify(IplImage *img, char side)
{
if (side == 'A')
cvRemap(img,img,mapxA,mapyA);
else
cvRemap(img,img,mapxB,mapyB);
}
*/