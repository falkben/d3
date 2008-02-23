[filename, pathname] = uigetfile({'*.avi','AVI file'; '*.*','Any file'},'Pick an AVI file');

%Open an handle to the AVI file
[avi_hdl, avi_inf] = dxAviOpen([pathname, filename]);

tic
cmap = colormap('gray');
mov = avifile('camera_1.avi', 'compression', 'none', 'colormap', cmap);
for frame_num = 1:avi_inf.NumFrames;
	%Reads frame_num from the AVI
	pixmap = dxAviReadMex(avi_hdl, frame_num);
	pixmap = reshape(pixmap/255,[avi_inf.Height,avi_inf.Width,3]);
    mov = addframe(mov,pixmap);
    if mod(frame_num, 3) == 0
        disp(['Frame:' num2str(frame_num)]);
    end
end
toc

%Cleanup
dxAviCloseMex(avi_hdl);
mov = close(mov);
aviinfo('camera_1')