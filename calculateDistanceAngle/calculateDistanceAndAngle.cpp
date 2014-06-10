
//return codes
// -1 problem with CLI arguments
// -2 problem with Intrinsic Values of camera
// -3 problem with Distortion Values of camera

#include <opencv2/core/core.hpp>
#include <opencv/cxcore.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv/cv.h>

#include <math.h>
#include <iostream>
#include "user.h"

using namespace std;


CvMat *intrinsicA = (CvMat*)cvLoad("IntrinsicsCamA.xml");
CvMat *distortionA = (CvMat*)cvLoad("DistortionCamA.xml");
CvMat *intrinsicB = (CvMat*)cvLoad("IntrinsicsCamB.xml");
CvMat *distortionB = (CvMat*)cvLoad("DistortionCamB.xml");



float alpha;
float beta;
float theta;
float Y;
float objDistance;

int main(int argc, char** argv)
{
	if (argc != 3) //check that all CLI arguments are passed
	{
		cout << " Usage: SRD_test.exe left_Image right_Image" << endl;
		return -1;
	}

	if (!intrinsicA)
	{
		cout << "Could not open or find IntrinsicsCamA.xml" << std::endl;
		return -2;
	}
	if (!intrinsicB)
	{
		cout << "Could not open or find IntrinsicsCamB.xml" << std::endl;
		return -2;
	}
	if (!distortionA)
	{
		cout << "Could not open or find DistortionCamA.xml" << std::endl;
		return -3;
	}
	if (!distortionB)
	{
		cout << "Could not open or find DistortionCamB.xml" << std::endl;
		return -3;
	}

	IplImage *imgA = cvLoadImage(argv[1]);

	if (!imgA) // Check for invalid input
	{
		cout << "Could not open or find left_Image" << std::endl;
		return -1;
	}

	imgA = singleCh(imgA);
	//IplImage *imgGreyA = cvCloneImage( imgA );
	biModal(imgA);
	undistortImg(imgA, intrinsicA, distortionA);
	CvPoint center = centerMass(imgA); //center hold the point that is the center of the can on a pinhole camera
	alpha = center.x;


	IplImage *imgB = cvLoadImage(argv[2]);

	if (!imgB) // Check for invalid input
	{
		cout << "Could not open or find right_Image" << std::endl;
		return -1;
	}

	imgB = singleCh(imgB);
	//IplImage *imgGreyB = cvCloneImage( imgB );
	biModal(imgB);
	undistortImg(imgB, intrinsicB, distortionB);
	CvPoint center1 = centerMass(imgB); //center hold the point that is the center of the can on a pinhole camera
	beta = center1.x;

	alpha = alpha2angle(alpha);
	beta = beta2angle(beta);
	alpha = deg2rad(alpha);
	beta = deg2rad(beta);

	//printf("alpha is %.2f and beta is %.2f \n",alpha, beta);

	//law of cosines to find the angle
	Y = (177 * sin(beta)) / (sin(180 - beta - alpha));
	printf("Y = %.2f \n", Y);
	objDistance = sqrt((8649 + pow(Y, 2)) - (186 * Y*cos(alpha)));
	theta = asin((Y*sin(alpha)) / (objDistance));
	theta = theta * 180 / 3.14159265;
	theta = theta - 90;


	printf("\n\nThe can is %.2f mm at an angle of %.2f \n\n", objDistance, theta);

	//Write int values for distance (mm) and angle (deg) into xml file for use by processing sketch
	CvFileStorage* fs = cvOpenFileStorage("Distance.xml", NULL, CV_STORAGE_WRITE);

	cvWriteInt(fs, "Distance", objDistance);
	cvWriteInt(fs, "Angle", theta);
	cvReleaseFileStorage(&fs);



	return objDistance;

}
