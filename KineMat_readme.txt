From: http://isbweb.org/software/movanal/kinemat/

KineMat

A MATLAB Toolbox for Three-Dimensional Kinematic Analyses
Christoph Reinschmidt, Ton van den Bogert
Human Performance Laboratory, The University of Calgary
January 1997
Description 
KineMat is a set of MATLAB function files written for the analysis of three-dimensional kinematics. KineMat is intended for intermediate to experienced MATLAB users.

KineMat provides the tools to build a motion analysis system tailored and customized to your needs. A simple example on how to use this toolbox is provided (demo1.m and demo2.m).

The KineMat toolbox can be used for two purposes: 
1. 3D Reconstruction: KineMat allows the reconstruction of the three-dimensional positions of markers seen in two or more cameras. Currently, KineMat uses a DLT (direct linear transformation) procedure with 11 coefficients. 
2. Motion Analysis: KineMat can be used to calculate transformation matrices, Cardan angles (Joint Coordinate System), and finite helical axes descriptors.

Remarks 
• Note that some of the functions are not written in a computationally efficient way, and may well be rewritten/optimized for faster computing. There is also the possibility to translate these MATLAB files into C by using the "MATLAB to C" compiler. 
• Transformation matrices (T) are expressed by 4x4 matrices containing both the 3x3 rotation matrix (R) and the translation vector (d): T=[R, d; 0, 0, 0, 1] 
• All m-files can be used on all platforms for which MATLAB is available. All m-file names are not longer than 8 characters and can therefore be used in windows (3.x) environments.

Disclaimer 
Even though KineMat has been tested and used in the past, the authors do not guarantee the correctness of these m-files. The use of this software is at your own risk.

Usage Policies 
KineMat can be used free of charge. The authors however request proper credit (citation or acknowledgments), if KineMat is used in publications or in any other forms of communication.

Support 
KineMat is not supported! However, if you find errors, have suggestions, concerns or additions to the existing library of m-files, contact either Christoph Reinschmidt (Christoph.Reinschmidt@sulzer.com) or Ton van den Bogert (bogert@bme.ri.ccf.org).

Acknowledgments 
KineMat was originally written for the analysis used in the thesis of C. Reinschmidt. During that process, financial support was received from the following institutions and agencies: the Swiss Federal Sports Commission (ESK Switzerland), the Olympic Oval Endowment Fund of Calgary, and adidas Research and Innovation.

The authors would also like to acknowledge the contribution of Ron Jacobs who wrote the first version of "soder.m".

How to Start 
1. Download kinemat.zip (or kinemat.tar.Z) and demo.zip (or demo.tar.Z). Extract the kinemat.zip-files into your MATLAB directory and create a directory where demo.zip is extracted to. 
2. Run demo1 and demo2 in MATLAB. 
3. Print out (or look at) demo1.m and demo2.m which give you more insight into the use of the various m-files used. 
4. Look at the various m-files. 


Short Description of the KineMat m-files 
A short description of the m-files contained in KineMat are given below. A more detailed description can be found on the first lines of the respective m-files (print out m-files or in MATLAB type "help functionname"). 
The appendix of my thesis also contains some additional information regarding the analysis of intersegmental motion: append.doc (winword file).
3D Reconstruction Tools: These set of programs allow to reconstruct the three-dimensional positions of markers seen in two or more cameras:
dltfu.m 	Calculates the (11) DLT coefficients for each camera based on digitized calibration points and the 3D coordinates of these calibration points.
 
reconfu.m 	Calculates spatial position X,Y,Z, residuals of the reconstruction, the cameras used from the DLT coefficients and the digitized marker coordinates of the different cameras.
Motion Analysis Tools: 
These set of programs are used to calculate transformation matrices, Cardan angles and corresponding translations (Joint Coordinate System), and finite helical axes descriptors:
angle2d.m 	Calculates the angle between 2 vectors in a plane. This program may also be used in conjunction with soder.m to calculate projected angles.
 
soder.m 	Calculates the rigid body transformation matrix (4x4) and residuals from three or more marker positions in coordinate system A and B.
 
cardan.m	This program calculates the intersegmental motion (cardan angles, and helical angles) between 2 segments. The required input is the position of the markers in the anatomical coordinate system of segment 1 and segment 2, the position of these markers during the movement in segment 1 and segment 2, and the chosen sequence. The program outputs the Cardan angles and helical angles (Woltring 1994, J. Biomechanics 27, 1399-1414).
 
rxyzsolv.m 	Calculates the Cardan angles ( and translations) using sequence xyz (first rotation about x fixed in first segment, y floating axis, and last rotation about z fixed in the second segment).
 
rxzysolv.m 	Same as above for sequence xzy
 
ryxzsolv.m 	Same as above for sequence yxz
 
ryzxsolv.m 	Same as above for sequence yzx
 
rzxysolv.m 	Same as above for sequence zxy
 
rzyxsolv.m 	Same as above for sequence zyx
 
screw.m 	Calculates finite helical angles descriptors (angle of rotation, translation along axis, and location of the axis in space)
Auxiliary Programs:
correct.m 	Checking of digitized camera coordinates. Let’s you interactively remove (correct) outliers.
 
deg2rad.m 	Converts degrees into radians.
 
distance.m 	Calculates the distance between two points.
 
invdlt.m 	This program calculates the local camera x,y coordinates of a known point in 3D using the (known) DLT coefficients of that camera. This program can for instance be used to plot finite helical axes into stereo x-rays. (similar procedure as used in Blankevoort et al. (1990), J.Biomechanics 21, 705-720).
 
marker.m 	Selects the appropriate column numbers for the specified marker.
 
normalfu.m 	Normalization program, e.g. normalizing data with respect to stance phase.
 
rad2deg.m 	Converts radians into degrees.
 