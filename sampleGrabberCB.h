/*
	Code based on GrabBitmaps.cpp in DirectShow samples (Direct X 9.0 SDK 2002)
	Ashwin Thangali <Feb 2006>
*/

//
// Implementation of CSampleGrabberCB object
//
// Note: this object is a SEMI-COM object, and can only be created statically.

class CSampleGrabberCB : public ISampleGrabberCB 
{

public:

    // These will get set by the main thread below. We need to
    // know this in order to write out the bmp
    long Width;
    long Height;
	unsigned char * pixmap;

    // Fake out any COM ref counting
    //
    STDMETHODIMP_(ULONG) AddRef() { return 2; }
    STDMETHODIMP_(ULONG) Release() { return 1; }

    // Fake out any COM QI'ing
    //
    STDMETHODIMP QueryInterface(REFIID riid, void ** ppv)
    {
        CheckPointer(ppv,E_POINTER);
        
        if( riid == IID_ISampleGrabberCB || riid == IID_IUnknown ) 
        {
            *ppv = (void *) static_cast<ISampleGrabberCB*> ( this );
            return NOERROR;
        }    

        return E_NOINTERFACE;
    }


    // We don't implement this one
    //
    STDMETHODIMP SampleCB( double SampleTime, IMediaSample * pSample )
    {
        return 0;
    }


    // The sample grabber is calling us back on its deliver thread.
    // This is NOT the main app thread!
    //
    STDMETHODIMP BufferCB( double SampleTime, BYTE * pBuffer, long BufferSize )
    {

		LPBYTE pData = (LPBYTE)pBuffer;
		
		int i,j, k,l,m, x,y, w,h;
		h = Height;
		w = Width;
		
		//printf("%s:%d buffersize %d w %d h %d %d\n",__FILE__,__LINE__, BufferSize, w, h, pixmap );
		
		if( pixmap != NULL){
			l = 0;
			for(j=0; j<3; j++){
				for(x=0; x<w; x++){
					k = 2 - j + 3*w*(h-1) + 3*x;
					for(y=0; y < h; y++){		
						pixmap[l] = pData[k];
						l++;
						k -= w * 3;
					}
				}
			}
		}
		else{
			char txt[1000];
			sprintf(txt,"%s:%d pixmap is NULL \n",__FILE__,__LINE__);
			mexErrMsgTxt(txt);
		}
		
		/* Write out ppm for debugging */
		/*
		unsigned char * test_buffer = NULL;
		test_buffer = new unsigned char[w*h*3];
		l = 0;
		for(y=0; y < h; y++){		
			k = 3*w*(h-y-1);
			for(x=0; x<w; x++){
				m = k + 2;
				for(j=0; j < 3; j++){		
					test_buffer[l] = pData[m];
					l++; m--;
				}
				k+=3;
			}
		}
		FILE * fp = fopen("test.ppm","wb");
		fprintf(fp,"P6\n%d %d\n255\n",w,h);
		fwrite(test_buffer, w*h*3, 1, fp);
		fclose(fp);
		printf("%s:%d test.ppm written\n",__FILE__,__LINE__);
		*/

        return 0;
    }
    STDMETHODIMP BufferCB_orig( double SampleTime, BYTE * pBuffer, long BufferSize )
    {
        //
        // Convert the buffer into a bitmap
        //
        TCHAR szFilename[MAX_PATH];
        wsprintf(szFilename, TEXT("Bitmap%5.5ld.bmp\0"), long( SampleTime * 1000 ) );

        // Create a file to hold the bitmap
        HANDLE hf = CreateFile(szFilename, GENERIC_WRITE, FILE_SHARE_READ, 
                               NULL, CREATE_ALWAYS, NULL, NULL );

        if( hf == INVALID_HANDLE_VALUE )
        {
            return 0;
        }

        printf("Found a sample at time %ld ms\t[%s]\r\n", long( SampleTime * 1000 ), szFilename );

        // Write out the file header
        //
        BITMAPFILEHEADER bfh;
        memset( &bfh, 0, sizeof( bfh ) );
        bfh.bfType = 'MB';
        bfh.bfSize = sizeof( bfh ) + BufferSize + sizeof( BITMAPINFOHEADER );
        bfh.bfOffBits = sizeof( BITMAPINFOHEADER ) + sizeof( BITMAPFILEHEADER );

        DWORD Written = 0;
        WriteFile( hf, &bfh, sizeof( bfh ), &Written, NULL );

        // Write the bitmap format
        //
        BITMAPINFOHEADER bih;
        memset( &bih, 0, sizeof( bih ) );
        bih.biSize = sizeof( bih );
        bih.biWidth = Width;
        bih.biHeight = Height;
        bih.biPlanes = 1;
        bih.biBitCount = 24;

        Written = 0;
        WriteFile( hf, &bih, sizeof( bih ), &Written, NULL );

        // Write the bitmap bits
        //
        Written = 0;
        WriteFile( hf, pBuffer, BufferSize, &Written, NULL );

        CloseHandle( hf );

        return 0;
    }
};
