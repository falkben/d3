[filename, pathname] = uigetfile({'*.avi','AVI file'; '*.*','Any file'},'Pick an AVI file');
for i=1:500;
	i
	[avi_hdl, avi_inf] = dxAviOpen([pathname,filename]);
	pixmap = dxAviReadMex(avi_hdl, 10);
	dxAviCloseMex(avi_hdl);
end
