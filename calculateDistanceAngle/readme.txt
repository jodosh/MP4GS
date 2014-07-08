Usage
=============

executable.exe left_Image right_Image



Assumptions
=============

The files IntrinsicsCamA.xml, DistortionCamA.xml, 
IntrinsicsCamB.xml, DistortionCamB.xml should be in the directory 
where the executable is. The files that end in A correspond to 
images on the left and B correspond to images on the right.

The object in question should be dark, and the background is nearly all white.


Output
==============

Distance.xml will be written with the distance and angle from the 
center of the line between the two cameras.