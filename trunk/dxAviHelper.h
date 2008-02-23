/*
	Code based on GrabBitmaps.cpp in DirectShow samples (Direct X 9.0 SDK 2002)
	Ashwin Thangali <Feb 2006>
*/

#include <Dshow.h>
#include <windows.h>
#include <streams.h>
#include <stdio.h>
#include <atlbase.h>
#include <qedit.h>

#include "sampleGrabberCB.h"
#include "helperFuncs.h"
#include <objbase.h>
#include <vfw.h>
#include <windowsx.h>
#include <math.h>

#include <mex.h>

WINOLEAPI  CoInitializeEx(IN LPVOID pvReserved, IN DWORD dwCoInit);

#define MEX_ERR mexErrMsgTxt(mex_err_str);

class dxAviHelper{
	public:
	int w, h, nframes;
	double fps, total_time_sec;

	CComPtr< ISampleGrabber > pGrabber;
	CComPtr< IBaseFilter >    pSource;
	CComPtr< IGraphBuilder >  pGraph;
	CComQIPtr< IBaseFilter > pGrabberBase;
	CComQIPtr< IFileSourceFilter > pLoad;
	CComQIPtr< IMediaSeeking> pSeeking;
	CComQIPtr< IMediaControl> pControl;
	CComQIPtr< IMediaEvent> pEvent;
	CComQIPtr< IVideoWindow > pWindow;
	CMediaType GrabType;
	CComPtr< IPin > pSourcePin;
	CComPtr< IPin > pGrabPin;
	CComPtr <IPin> pGrabOutPin;
	CSampleGrabberCB CB;
	VIDEOINFOHEADER * vih;
	AVIFILEINFO avi_info;

	char mex_err_str[10000];

	void getAviInfo(char * fname){
		PAVIFILE pfile;
		HRESULT hr;
		AVIFileInit();
		hr = AVIFileOpen(   &pfile,		    // returned file pointer
							fname,			// file name
							OF_READ,		// mode to open file with OF_READ/OF_CREATE/OF_READWRITE
							NULL);			// use handler determined
		if (hr != AVIERR_OK) {
			sprintf(mex_err_str,"%s:%d AVIFileOpen failed on file %s\n",__FILE__,__LINE__,fname); MEX_ERR 
			return;
		}

		hr = AVIFileInfo(	pfile,  
							&avi_info,
							sizeof(AVIFILEINFO) );
		if (hr != AVIERR_OK){
			sprintf(mex_err_str,"%s:%d AVIStreamInfo failed on file %s\n",__FILE__,__LINE__,fname); MEX_ERR
			return;
		}
		AVIFileClose(pfile);
	}
	dxAviHelper(char * fname){
		getAviInfo(fname);

    	CoInitializeEx(NULL, COINIT_APARTMENTTHREADED); //
		
		USES_CONVERSION;
		HRESULT hr;

		// Create the sample grabber
		//
		pGrabber.CoCreateInstance( CLSID_SampleGrabber );
		if( !pGrabber )
		{
			printf( "Could not create CLSID_SampleGrabber\r\n") ;
		}
		CComQIPtr< IBaseFilter, &IID_IBaseFilter > tGrabberBase( pGrabber );
		pGrabberBase = tGrabberBase;

		// Create the file reader
		//
		pSource.CoCreateInstance( CLSID_AsyncReader );
		if( !pSource )
		{
			sprintf(mex_err_str, "Could not create source filter\r\n"); MEX_ERR
		}

		// Create the graph
		//
		pGraph.CoCreateInstance( CLSID_FilterGraph );
		if( !pGraph )
		{
			sprintf(mex_err_str, "Could not not create the graph\r\n"); MEX_ERR
		}

		// Put them in the graph
		//
		hr = pGraph->AddFilter( pSource, L"Source" );
		hr = pGraph->AddFilter( pGrabberBase, L"Grabber" );

		// Load the source
		//
		CComQIPtr< IFileSourceFilter, &IID_IFileSourceFilter > tLoad( pSource );
		pLoad = tLoad;
		hr = pLoad->Load( T2W( fname ), NULL );
		if( FAILED( hr ) )
		{
			sprintf(mex_err_str, "Could not load the media file\r\n"); MEX_ERR
		}

		// Tell the grabber to grab 24-bit video. Must do this
		// before connecting it
		//
		GrabType.SetType( &MEDIATYPE_Video );
		GrabType.SetSubtype( &MEDIASUBTYPE_RGB24 );
		hr = pGrabber->SetMediaType( &GrabType );

		// Get the output pin and the input pin
		pSourcePin = GetOutPin( pSource, 0 );
		pGrabPin   = GetInPin( pGrabberBase, 0 );

		// ... and connect them
		//
		hr = pGraph->Connect( pSourcePin, pGrabPin );
		if( FAILED( hr ) )
		{
			sprintf(mex_err_str, "Could not connect source filter to grabber\r\n"); MEX_ERR
		}

		// This semi-COM object will receive sample callbacks for us
		//

		// Ask for the connection media type so we know its size
		//
		AM_MEDIA_TYPE mt;
		hr = pGrabber->GetConnectedMediaType( &mt );

		vih = (VIDEOINFOHEADER*) mt.pbFormat;
		CB.Width  = vih->bmiHeader.biWidth;
		CB.Height = vih->bmiHeader.biHeight;
		w = CB.Width;
		h = CB.Height;
		CB.pixmap = new unsigned char[w*h*3];
		FreeMediaType( mt );

		// Render the grabber output pin (to a video renderer)
		//
		pGrabOutPin = GetOutPin( pGrabberBase, 0 );
		hr = pGraph->Render( pGrabOutPin );
		if( FAILED( hr ) )
		{
			sprintf(mex_err_str, "Could not render grabber output pin\r\n"); MEX_ERR
		}

		// Don't buffer the samples as they pass through
		//
		hr = pGrabber->SetBufferSamples( FALSE );

		// Only grab one at a time, stop stream after
		// grabbing one sample
		//
		hr = pGrabber->SetOneShot( TRUE );

		// Set the callback, so we can grab the one sample
		//
		hr = pGrabber->SetCallback( &CB, 1 );

		// Query the graph for the IVideoWindow interface and use it to
		// disable AutoShow.  This will prevent the ActiveMovie window from
		// being displayed while we grab bitmaps from the running movie.
		CComQIPtr< IVideoWindow, &IID_IVideoWindow > tWindow = pGraph;
		pWindow = tWindow;
		if (pWindow)
		{
			hr = pWindow->put_AutoShow(OAFALSE); //FALSE
		}

		// Get the seeking interface, so we can seek to a location
		//
		CComQIPtr< IMediaSeeking, &IID_IMediaSeeking > tSeeking( pGraph );
		pSeeking = tSeeking;

        CComQIPtr< IMediaControl, &IID_IMediaControl > tControl( pGraph );
		pControl = tControl;

        CComQIPtr< IMediaEvent, &IID_IMediaEvent > tEvent( pGraph );
		pEvent = tEvent;

        REFERENCE_TIME Start = 0;
        hr = pSeeking->SetPositions( &Start, AM_SEEKING_AbsolutePositioning, 
                                     NULL, AM_SEEKING_NoPositioning );
		LONGLONG t;
		pSeeking->GetDuration(&t);
		total_time_sec = (double)t/1e7;
		fps = (double)avi_info.dwRate/avi_info.dwScale;
		nframes = floor(fps*total_time_sec);

		//printf("%s:%d %f %.0lf %d\n",__FILE__,__LINE__,fps, (double)total_time_sec, nframes);
		//readFrame(100, NULL);
	}
	void readFrame(double frame_pos_sec, double * pixmap){
		HRESULT hr;

		// set position
        REFERENCE_TIME Start = frame_pos_sec * UNITS;
		//printf("%s:%d %d %d %f %f\n",__FILE__,__LINE__,w,h,frame_pos_sec,Start);
        hr = pSeeking->SetPositions( &Start, AM_SEEKING_AbsolutePositioning, 
                                     NULL, AM_SEEKING_NoPositioning );
		if( FAILED( hr ) )
		{
			sprintf(mex_err_str, "Could not seek to %fs\r\n",Start); MEX_ERR
		}

        // activate the threads
        hr = pControl->Run( );
		if( FAILED( hr ) )
		{
			sprintf(mex_err_str, "Could not run\r\n"); MEX_ERR
		}

        // wait for the graph to settle
        long EvCode = 0;
        hr = pEvent->WaitForCompletion( INFINITE, &EvCode );
		if( FAILED( hr ) )
		{
			sprintf(mex_err_str, "Could not wait for complete\r\n"); MEX_ERR
		}
        // callback wrote the sample

		if( pixmap != NULL){
			for(int i=0; i<3*w*h; i++)
				pixmap[i] = CB.pixmap[i];
		}
	}
	void close(){
		delete [] CB.pixmap;
        /*
		delete vih;
		delete pEvent;
		delete pControl;
		delete pSeeking;
		delete pWindow;
        delete pGrabOutPin;
		delete pGrabPin;
		delete pSourcePin;
		delete pLoad;
		delete pGrabberBase;
		delete pGraph;
		delete pSource;
		delete pGrabber;
        */
    	CoUninitialize();
	}
};

