#include <mex.h>
#include "dxAviHelper.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[]){
	dxAviHelper * avi_helper;
	char * fname, *buffer;
	int buflen, frame_no;
	double * ip, fps, num_frames;
	buflen = mxGetN(prhs[0])*sizeof(mxChar)+1;
	fname = new char[buflen+10];
	mxGetString(prhs[0], fname, buflen);

	//Setup the avi_helper object
	avi_helper = new dxAviHelper(fname);

	buflen = sizeof(dxAviHelper);
	plhs[0] = mxCreateDoubleMatrix(buflen/sizeof(double)+1, 1, mxREAL);
	buffer = (char*)mxGetPr(plhs[0]);
	memcpy(buffer, avi_helper, buflen);

	plhs[1] = mxCreateDoubleMatrix(5, 1, mxREAL);
	double * out = mxGetPr(plhs[1]);
	out[0] = avi_helper -> w;
	out[1] = avi_helper -> h;
	out[2] = avi_helper -> nframes;
	out[3] = avi_helper -> fps;
	out[4] = avi_helper -> total_time_sec;
	delete fname;
}

