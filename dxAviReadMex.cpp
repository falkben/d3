#include <mex.h>
#include "dxAviHelper.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[]){
	dxAviHelper * avi_helper;
	int buflen, frame_no, dims[1];
	double * buffer, frame_time;
	avi_helper = (dxAviHelper *)mxGetPr(prhs[0]);
	frame_no = (int)mxGetScalar(prhs[1]);
	if( frame_no > avi_helper -> nframes || frame_no < 1){
		printf("dxAviReadMex: input frame number should be in [1, #frames] \n", frame_no, avi_helper -> nframes);
		plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
		return;
	}
	
	buflen = avi_helper->w * avi_helper->h*3;
	plhs[0] = mxCreateDoubleMatrix(buflen, 1, mxREAL);
	buffer = mxGetPr(plhs[0]);
	
	frame_time = (frame_no - 1) / avi_helper -> fps;
	//printf("%s:%d %d %d %f %f\n",__FILE__,__LINE__,avi_helper -> w, avi_helper -> h, frame_time, avi_helper -> fps);
	avi_helper -> readFrame(frame_time, buffer);
}
