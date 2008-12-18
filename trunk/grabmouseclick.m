function grabmouseclick(handles)
global D3_GLOBAL
global running

if running == 1
    return;
end

%is mouse button within axes
scrn_pt = get(0,'PointerLocation');%gives us absolute mouse position
axes_pos = get(handles.axes1,'position');
figure_pos = get(handles.figure1,'position');

cursor_position = scrn_pt - figure_pos(1:2) - axes_pos(1:2);
if(...
    (cursor_position(1) > 0) &...
    (cursor_position(2) > 0) &...
    (cursor_position(1) < axes_pos(3)) &...
    (cursor_position(2) < axes_pos(4))...
    )
    %find out where we clicked...
    blah = get(handles.axes1,'currentpoint');%gives x,y,z of the current pozition
                                             %if click is within axes
    D3_GLOBAL.internal.x = blah(1,1);%we need this since this fun returns corners of a voxel that we clicked (we think)
    D3_GLOBAL.internal.y = blah(1,2);    
    
    %store click
    
    %advance frame/point
    counter = 0 ;
    d3('get_next_frame')
        %kill switch check
        %drawnow ;
%         if get(D3_GLOBAL.handles.kill_box,'value')
%             break;
%         end
    
    
end