% 2010.01.06 : ALL CHANGES SHOULD BE NOTED IN THE D3 SUBVERSION REPOSITORY
%              LOG (WHEN YOU COMMIT). --Scott Livingston

function varargout = d3(varargin)
global D3_GLOBAL

% D3 Application M-file for d3.fig
%    FIG = D3 launch d3 GUI.
%    D3('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 25-Apr-2014 14:23:47

if nargin == 0  % LAUNCH GUI
  
  fig = openfig(mfilename,'reuse');
  
  % Generate a structure of handles to pass to callbacks, and store it.
  handles = guihandles(fig);
  
  %    D3_GLOBAL.handles = handles ;
  guidata(fig, handles);
  
  initialise_all(handles);
  
  if nargout > 0
    varargout{1} = fig;
  end
  
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  
  try
    if (nargout)
      [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else
      feval(varargin{:}); % FEVAL switchyard
    end
  catch
    disp(lasterr);
  end
  
end

% --------------------------------------------------------------------
% called when we wanna change paths
function varargout = menu_paths_Callback(h, eventdata, handles, varargin)

if ispref('d3_path','video') && exist(getpref('d3_path','video'),'dir')
  video_dir = getpref('d3_path','video');
else
  video_dir = pwd;
end

if ispref('d3_path','analyzed_path') && exist(getpref('d3_path','analyzed_path'),'dir')
  analyzed_dir =getpref('d3_path','analyzed_path');
else
  analyzed_dir = pwd;
end

[pathname] = uigetdir(video_dir, 'Locate raw video folder (cancel to skip)');
if ~(pathname==0)
  setpref('d3_path','video',pathname);
end

[pathname] = uigetdir(analyzed_dir, 'Locate folder to save analyzed files (cancel to skip)');
if ~(pathname==0)
  setpref('d3_path','analyzed_path',pathname);
end


%called when d3 starts up, loads preferences
function initialise_all(handles)
global D3_GLOBAL
global running

running = 0;

d3version = '2.1';

disp('D3');
disp(['Version ' d3version]);
disp('This version requires MATLAB R2010b or newer (VideoReader)');
disp('Developers:');
disp('  Murat Aytekin <aytekin@umd.edu>,');
disp('  Ben Falk <bfalk@umd.edu>,');
disp('  Kaushik Ghose <kghose@gmail.com>,');
disp('  Wei Xian <wxian@psyc.umd.edu>,');
disp('  Scott Livingston <slivingston@caltech.edu>');

if ~ispref('d3_path','video')
  [pathname] = uigetdir(pwd, 'Locate video folder');
  setpref('d3_path','video',pathname);
end

if ~ispref('d3_path','analyzed_path')
  [pathname] = uigetdir(pwd, 'Locate folder to save analyzed files (cancel to skip)');
  setpref('d3_path','analyzed_path',pathname);
end

D3_GLOBAL = [];

% D3_GLOBAL.vid_dir = vid_dir ;
% D3_GLOBAL.motus_export_dir = motus_export_dir ;

D3_GLOBAL.handles = handles ;

% These are stored as separate matrices in D3_GLOBAL, and then
% merged (into a matrix called ignore_segs) when saving trial data
% to a *_d3.mat type file. These matrices are kept separate when saving
% to the *.d3 type file (now a field under the whole_trial structure).
%
% Engineering notes like this should be moved to a technical document that
% (fully) describes d3.
D3_GLOBAL.ignore_segs_cam1 = [];
D3_GLOBAL.ignore_segs_cam2 = [];

D3_GLOBAL.cam(1).name = [];
D3_GLOBAL.cam(2).name = [];
D3_GLOBAL.max_frames = [];
D3_GLOBAL.current_frame = [];
D3_GLOBAL.current_point = [];
D3_GLOBAL.camera = [];
D3_GLOBAL.remember_zoom = 0 ;

D3_GLOBAL.trial_params.fvideo=250;
set(handles.frame_rate,'String',num2str(D3_GLOBAL.trial_params.fvideo)) ; %need a way to change this

%everything is based on the frame rate and the start and end frames,
%once we set framerate, we can set the times
set_time_frame_parameters(handles);

D3_GLOBAL.trial_params.interaction_time = .5 ;
D3_GLOBAL.trial_params.trial_start = -8.504 ;
D3_GLOBAL.trial_params.trial_end = 0 ;
D3_GLOBAL.trial_params.clip(1).start=-8.504;
D3_GLOBAL.trial_params.clip(2).start=-8.504;

D3_GLOBAL.rawdata.point.cam(1).coordinate = [];
D3_GLOBAL.rawdata.point.cam(2).coordinate = [];
D3_GLOBAL.rawdata.smoothened_point = D3_GLOBAL.rawdata.point ;

D3_GLOBAL.reconstructed.point = [];

D3_GLOBAL.internal.quantization_level = 'none';
D3_GLOBAL.internal.playback_speed = 30 ; %this should be fixed
D3_GLOBAL.internal.cam_speed(1) = 30 ;
D3_GLOBAL.internal.cam_speed(2) = 30 ;
D3_GLOBAL.internal.file_name = '' ;

D3_GLOBAL.d3_analysed.startframe = -2126 ;
D3_GLOBAL.d3_analysed.endframe = 0 ;

%reset the GUI
cla(D3_GLOBAL.handles.axes_3d,'reset');
set(D3_GLOBAL.handles.trial_start_frame_edit,'String','-2126');
set(D3_GLOBAL.handles.trial_end_frame_edit,'String','0');
set(D3_GLOBAL.handles.clip_start_c1_frame_edit,'String','-2126');
set(D3_GLOBAL.handles.clip_start_c2_frame_edit,'String','-2126');
set(D3_GLOBAL.handles.clip_start_c1_edit,'String','-8.504');
set(D3_GLOBAL.handles.clip_start_c2_edit,'String','-8.504');
set(D3_GLOBAL.handles.trial_start_edit,'String','-8.504');
set(D3_GLOBAL.handles.trial_end_edit,'String','0');
set(D3_GLOBAL.handles.trialcode_edit,'String','');
set(D3_GLOBAL.handles.frame_rate,'String','250');
set(D3_GLOBAL.handles.dlt_display_edit,'String','DLT not computed');
set(D3_GLOBAL.handles.quantization_popup,'Value',1);

set(D3_GLOBAL.handles.frame_rate,'BackgroundColor',[1 48/255 48/255]);

% --------------------------------------------------------------------
function varargout = camera_select_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL
D3_GLOBAL.camera = get(handles.camera_select,'value');

%because the other camera could have a different image and needs updating
try
  load_video_frame(false);
  update_cam_fname_edit(handles);
catch
end

update(handles);


function update_cam_fname_edit(handles)
global D3_GLOBAL

if get(handles.mode_popup,'value') == 2
  set(handles.cam_fname_edit,'Visible','On');
  indices = strfind(D3_GLOBAL.cam(D3_GLOBAL.camera).name,'\');
  indx = indices(end);
  fname = D3_GLOBAL.cam(D3_GLOBAL.camera).name(indx+1:end);
  set(handles.cam_fname_edit,'String',fname);
  set(handles.cam_fname_edit,'ToolTipString',D3_GLOBAL.cam(D3_GLOBAL.camera).name);
else
  set(handles.cam_fname_edit,'Visible','Off');
end

% --------------------------------------------------------------------
function varargout = frame_slider_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL
global running

if running == 1
  return;
end

D3_GLOBAL.current_frame = fix(get(handles.frame_slider,'value'));
set(handles.frame_edit,'string',num2str(D3_GLOBAL.current_frame));
set(handles.frame_slider,'value',D3_GLOBAL.current_frame);
load_video_frame(false) ;
update(handles);

% --------------------------------------------------------------------
function varargout = frame_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.current_frame = fix(min(max(1,str2double(get(handles.frame_edit,'string'))), D3_GLOBAL.max_frames))  ;
set(handles.frame_slider,'value',D3_GLOBAL.current_frame);
set(handles.frame_edit,'string',num2str(D3_GLOBAL.current_frame));
load_video_frame(false) ;
update(handles);


% --------------------------------------------------------------------
function varargout = mode_popup_Callback(h, eventdata, handles, varargin)
mode_changed(handles);
update(handles);


% --------------------------------------------------------------------
function varargout = advance_mode_radio_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = data_menu_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = data_export_menu_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = Trial_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = trial_calibration_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = trial_spatial_model_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = load_spatial_model_Callback(h, eventdata, handles, varargin)
load_spatial_model(handles);
update(handles);

function load_spatial_model(handles)
global D3_GLOBAL

waitfor(select_spatial_model);

for n = 1:length(D3_GLOBAL.spatial_model.point)
  D3_GLOBAL.reconstructed.point(n).pos = [];
end
if (get(handles.mode_popup,'value') == 2) %digitizing, need to update the spatial model points
  mode_changed(handles);
end


% --------------------------------------------------------------------
function new_spatial_model_Callback(hObject, eventdata, handles)
% hObject    handle to new_spatial_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(new_spatial_model);


% open GUI to handle new calibration file
% --------------------------------------------------------------------
function varargout = new_calibration_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.remember_zoom = 0;

waitfor(select_calib) ;

%now put program in calibration mode
set(handles.mode_popup,'value',1);
mode_changed(handles);
update(handles);

% load existing calibration file
% --------------------------------------------------------------------
function varargout = load_calibration_Callback(h, eventdata, handles, varargin)
load_calibration(handles);

function load_calibration(handles)
global D3_GLOBAL

D3_GLOBAL.remember_zoom = 0;

[filename, pathname] = uigetfile( {'*.clb';'*.*'},'Load Calibration');
if (filename)==0
  return
end
load([pathname '/' filename],'-MAT');
D3_GLOBAL.calibration = variable ;
mode_changed(handles);
update(handles);


% save calibration data under some name
% --------------------------------------------------------------------
function varargout = save_calibration_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

[filename, pathname] = uiputfile( {'*.clb';'*.*'},'Save as');
if filename == 0
  return
end

if length(filename) > 4
  if ~strcmp(filename(length(filename)-3:length(filename)),'.clb')
    filename = [filename '.clb'];
  end
else
  %no extension ?
  filename = [filename '.clb'];
end

variable = D3_GLOBAL.calibration ; %#ok<NASGU>
save([pathname '/' filename],'variable');

% --------------------------------------------------------------------
function varargout = trial_save_as_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.internal.file_name = [];
trial_save_Callback(h, eventdata, handles, varargin);



% save existing trial
% --------------------------------------------------------------------
function varargout = trial_save_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

if isfield(D3_GLOBAL, 'buffer')
  D3_GLOBAL=rmfield(D3_GLOBAL,'buffer');
end

tcode = get(handles.trialcode_edit,'string');
tstart = D3_GLOBAL.trial_params.trial_start ;
startframe = round(tstart * D3_GLOBAL.trial_params.fvideo) ; %not the start of the data but the start of the video data, according to the db

if ~isfield(D3_GLOBAL.internal,'file_name')
  D3_GLOBAL.internal.file_name = '';
end

if ispref('d3_path','analyzed_path')
  pn = [getpref('d3_path','analyzed_path') '\'];
else
  pn = './';
end

if ~exist(pn,'dir')
  pn = './';
  disp('Your analyzed video path variable points to a non existant directory.');
end

%save trial as simply erases this internal filename and calls this function
if isempty(D3_GLOBAL.internal.file_name)
  [filename, pathname] = uiputfile( [pn tcode '_' num2str(startframe) '.d3'],'Save trial as');
  if filename == 0
    return
  end
  D3_GLOBAL.internal.file_name = [pathname filename];
end

fn = D3_GLOBAL.internal.file_name;

if length(fn) > 3
  if strcmp(fn(end-2:end), '.d3') == 0
    fn = [fn '.d3'];
  end
else
  % No extension?
  fn = [fn '.d3'];
end

D3_GLOBAL.internal.file_name = fn ;

whole_trial = D3_GLOBAL ;

%don't save the space wasting image data
whole_trial.calibration.image = [];
whole_trial.image = [];

try
  save(whole_trial.internal.file_name,'whole_trial');
catch
  %something didn't work out :(
  [filename, pathname] = uiputfile( [pn  tcode '_' num2str(startframe) '.d3'],'Save trial as');
  if filename == 0
    return
  end
  whole_trial.internal.file_name = [pathname filename];
  D3_GLOBAL.internal.file_name = [pathname filename];
  save(whole_trial.internal.file_name,'whole_trial');
end
disp(['saved: ' whole_trial.internal.file_name]);



% load existing trial
% --------------------------------------------------------------------
function varargout = trial_load_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

%ask if we need to save old trial
ButtonName=questdlg('Open another trial?  Note that unsaved changes to the current trial will be lost.', ...
  'Open Trial', ...
  'Yes','No','Save current trial first','No');

switch ButtonName,
  case 'No',
    return;
  case 'Save old trial first',
    trial_save_Callback(h, eventdata, handles, varargin);
    
end % switch

if ispref('d3_path','analyzed_path')
  pn = [getpref('d3_path','analyzed_path') '\'];
else
  pn = './';
end

if ~exist(pn,'dir')
  disp('Cannot find your analyzed files directory.  Please check your paths.');
end
[filename, pathname] = uigetfile([pn '*.d3'],'Load trial');
if isequal(pathname,0)
  return
end

load([pathname filename],'-MAT');
D3_GLOBAL = whole_trial ;
D3_GLOBAL.handles = handles ;
D3_GLOBAL.remember_zoom = 0;

if ~isfield(D3_GLOBAL,'tcode')
  %forces people to enter trial code in my format
  prompt={'Year','Month','Day','Session','Trial#'};
  def={'2004','01','01','1','01'};
  dlgTitle='New trial';
  lineNo=1;
  answer=inputdlg(prompt,dlgTitle,lineNo,def);
  if ~isempty(answer)
    yr = answer{1};
    mo = answer{2};
    dy = answer{3};
    se = answer{4};
    tr = answer{5};
    tc = [yr(1:4) '.' mo(1:2) '.' dy(1:2) '.' se(1) '.' tr(1:2)];
    D3_GLOBAL.tcode = tc;
    set(gcf,'Name',['3-d: ' D3_GLOBAL.tcode],'NumberTitle','off');
  else
    warndlg('You have refused to enter trial date. Continue at your own risk.','No trial code');
    D3_GLOBAL.tcode = 'none';
    set(gcf,'Name','3-d:','NumberTitle','off');
  end
  
else
  set(gcf,'Name',['3-d: ' D3_GLOBAL.tcode],'NumberTitle','off');
end

set(D3_GLOBAL.handles.clip_start_c1_edit,'string',num2str(D3_GLOBAL.trial_params.clip(1).start));
set(D3_GLOBAL.handles.clip_start_c2_edit,'string',num2str(D3_GLOBAL.trial_params.clip(2).start));
set(D3_GLOBAL.handles.trial_start_edit,'string',num2str(D3_GLOBAL.trial_params.trial_start));
set(D3_GLOBAL.handles.trial_end_edit,'string',num2str(D3_GLOBAL.trial_params.trial_end));
set(D3_GLOBAL.handles.clip_start_c1_frame_edit,'string',num2str(D3_GLOBAL.trial_params.clip(1).start * D3_GLOBAL.trial_params.fvideo));
set(D3_GLOBAL.handles.clip_start_c2_frame_edit,'string',num2str(D3_GLOBAL.trial_params.clip(2).start * D3_GLOBAL.trial_params.fvideo));
set(D3_GLOBAL.handles.trial_start_frame_edit,'string',num2str(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo));
set(D3_GLOBAL.handles.trial_end_frame_edit,'string',num2str(D3_GLOBAL.trial_params.trial_end * D3_GLOBAL.trial_params.fvideo));
set(D3_GLOBAL.handles.trialcode_edit,'string',D3_GLOBAL.tcode);
set(D3_GLOBAL.handles.frame_rate,'string',D3_GLOBAL.trial_params.fvideo);

startframe =  round(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo) ;
endframe =  round(D3_GLOBAL.trial_params.trial_end * D3_GLOBAL.trial_params.fvideo) ;
set(handles.db_frame_text,'string',[ num2str(startframe) ' , ' num2str(endframe)]);

load_trial_video(handles,1);
load_trial_video(handles,2);
mode_changed(handles) ; %to get the points to show...
update(handles);


% make a new trial
% --------------------------------------------------------------------
function varargout = trial_new_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

%ask if we need to save old trial
ButtonName=questdlg( 'Start new trial?  Note that any unsaved work will be lost.', ...
  'New Trial Confirmation', 'Yes', 'No', 'No' );

switch ButtonName,
  case 'Yes'
    % continue
  case 'No'
    return % "New trial" sequence cancelled.
  otherwise
    return;
end % switch

%wipe data for old trial and start afresh
initialise_all(handles);

%load calibration
set(handles.mode_popup,'value',1);
load_calibration(handles);

%load spatial model
load_spatial_model(handles);

%load camera videos
load_video_file(handles,1);
load_video_file(handles,2);

update(handles);


% --------------------------------------------------------------------
function mode_changed(handles)
global D3_GLOBAL
persistent advance_mode %= get(handles.advance_mode_radio,'value');

D3_GLOBAL.remember_zoom = 0;

if isempty(advance_mode)
  advance_mode = get(handles.advance_mode_radio,'value');
end

mode = get(handles.mode_popup,'value');

switch(mode)
  case 1 %calibration
    %get n points for calib frame and put them in the string for the popup
    try
      name = cell(size(D3_GLOBAL.calibration.point,1),1);
      for k=1:size(D3_GLOBAL.calibration.point,1)
        name{k} = ['point ' num2str(k)];
      end
    catch
      name = 'No calibration point';
    end
    
    D3_GLOBAL.current_point = 1 ;
    set(handles.point_select_popup,'value',1);
    set(handles.point_select_popup,'string',name);
    
    %make frame slider and other objects vanish
    set(handles.frame_slider,'visible','off');
    set(handles.frame_edit,'visible','off');
    set(handles.play_button,'visible','off');
    advance_mode = get(handles.advance_mode_radio,'value');
    set(handles.advance_mode_radio,'value',0,'visible','off');
    
    
    update_cam_fname_edit(handles);
    
  case 2 %digitization
    %get n points for digitization and put them in the string for the popup
    name = cell(length(D3_GLOBAL.spatial_model.point),1);
    for k=1:length(D3_GLOBAL.spatial_model.point)
      name{k} = D3_GLOBAL.spatial_model.point(k).name;
    end
    set(handles.point_select_popup,'string',name);
    point_changed(handles);
    
    %make frame slider reappear
    set(handles.frame_slider,'visible','on');
    set(handles.frame_edit,'visible','on');
    set(handles.play_button,'visible','on');
    set(handles.advance_mode_radio,'value',advance_mode,'visible','on');
    
    update_cam_fname_edit(handles);
end

% --------------------------------------------------------------------
function update(handles)
global D3_GLOBAL

%get current zoom and hold it
Xlim = get(handles.axes1,'xlim');
Ylim = get(handles.axes1,'ylim');

%set the camera
D3_GLOBAL.camera = get(handles.camera_select,'value');

hold off;%just to make sure...

%do according to mode
mode = get(handles.mode_popup,'value');
switch(mode)
  case 1 %calibration
    try
      axes(handles.axes1);
      M = image_manipulation(D3_GLOBAL.calibration.image(D3_GLOBAL.camera).c.cdata);
      imagesc(M); colormap gray; hold on;
      for n=1:size(D3_GLOBAL.calibration.cam(D3_GLOBAL.camera).point,1)
        plot(D3_GLOBAL.calibration.cam(D3_GLOBAL.camera).point(n,1),D3_GLOBAL.calibration.cam(D3_GLOBAL.camera).point(n,2),'*');
        text(D3_GLOBAL.calibration.cam(D3_GLOBAL.camera).point(n,1),D3_GLOBAL.calibration.cam(D3_GLOBAL.camera).point(n,2),['point ' num2str(n)]);
      end
      hold off;
    catch
    end
  case 2 %digitization
    axes(handles.axes1);
    try
      M = image_manipulation(D3_GLOBAL.image(D3_GLOBAL.camera).c.cdata);
    catch
      %fake it
      M = zeros(480,640);
    end
    imagesc(M);hold on; colormap gray ;
    
    for n=1:length(D3_GLOBAL.rawdata.point)
      
      if size(D3_GLOBAL.rawdata.point(n).cam(D3_GLOBAL.camera).coordinate,1) >= D3_GLOBAL.current_frame
        point_x = D3_GLOBAL.rawdata.point(n).cam(D3_GLOBAL.camera).coordinate(D3_GLOBAL.current_frame  ,1);
        point_y = D3_GLOBAL.rawdata.point(n).cam(D3_GLOBAL.camera).coordinate(D3_GLOBAL.current_frame  ,2);
        plot(point_x, point_y,['*' ...
          D3_GLOBAL.spatial_model.point(n).color ]);
        if get(handles.show_point_names,'value')
          text(point_x, point_y,D3_GLOBAL.spatial_model.point(n).name,...
            'color','w')
        end
      end

      %plot the trace

      if get(D3_GLOBAL.handles.plot_trajectory_check,'value')
        point_x = D3_GLOBAL.rawdata.point(n).cam(D3_GLOBAL.camera).coordinate...
          (1:min(size(D3_GLOBAL.rawdata.point(n).cam(D3_GLOBAL.camera).coordinate,1),D3_GLOBAL.current_frame),1);
        point_y = D3_GLOBAL.rawdata.point(n).cam(D3_GLOBAL.camera).coordinate...
          (1:min(size(D3_GLOBAL.rawdata.point(n).cam(D3_GLOBAL.camera).coordinate,1),D3_GLOBAL.current_frame),2);
        h=plot(point_x, point_y, D3_GLOBAL.spatial_model.point(n).color);
        set(h,'linewidth',2);

        try
          point_x = D3_GLOBAL.rawdata.smoothened_point(n).cam(D3_GLOBAL.camera).coordinate...
            (1:min(size(D3_GLOBAL.rawdata.smoothened_point(n).cam(D3_GLOBAL.camera).coordinate,1),D3_GLOBAL.current_frame),1);
          point_y = D3_GLOBAL.rawdata.smoothened_point(n).cam(D3_GLOBAL.camera).coordinate...
            (1:min(size(D3_GLOBAL.rawdata.smoothened_point(n).cam(D3_GLOBAL.camera).coordinate,1),D3_GLOBAL.current_frame),2);
          plot(point_x, point_y, 'w:');
        end
      end
      
    end% cycle through all the points
    
    hold off;
    
end

if D3_GLOBAL.remember_zoom
  set(handles.axes1,'xlim',Xlim,'ylim',Ylim);
else
  D3_GLOBAL.remember_zoom = 1;
end

set(handles.frame_edit,'string',num2str(D3_GLOBAL.current_frame));
set(handles.frame_slider,'value',D3_GLOBAL.current_frame);



% is called by grabmouseclick (which is called directly as a callback from the UI when clicked)
% this actually advances either the frame or the point or both depending on the mode and point and frame
function get_next_frame
global D3_GLOBAL

set(D3_GLOBAL.handles.x_click_text,'string',['x = ' num2str(D3_GLOBAL.internal.x)]);
set(D3_GLOBAL.handles.y_click_text,'string',['y = ' num2str(D3_GLOBAL.internal.y)]);


%set clicked point here
switch get(D3_GLOBAL.handles.mode_popup,'value')
  case 1 %calibration
    D3_GLOBAL.calibration.cam(D3_GLOBAL.camera).point(D3_GLOBAL.current_point,:) = [D3_GLOBAL.internal.x D3_GLOBAL.internal.y];
    
  case 2 %digitization
    D3_GLOBAL.rawdata.point(D3_GLOBAL.current_point).cam(D3_GLOBAL.camera).coordinate(D3_GLOBAL.current_frame ,:) =...
      [D3_GLOBAL.internal.x D3_GLOBAL.internal.y];
end

%check mode
mode = get(D3_GLOBAL.handles.advance_mode_radio,'value');

switch mode
  case 0 %advance once all points have been done
    if advance_point == 1 %we are out of points
      if advance_frame == 1 %we are also out of frames
        uiwait(msgbox('Camera done'));
        disp('cam done');
      end
    end
    
  case 1
    if advance_frame == 1 %we are out of frames
      if advance_point == 1 %we are also out of points
        uiwait(msgbox('Camera done'));
        disp('cam done');
      end
    end
end

update(D3_GLOBAL.handles);



%end_points =1 if we are out of points
function [end_points] = advance_point
global D3_GLOBAL


switch get(D3_GLOBAL.handles.mode_popup,'value')
  case 1 %calibration
    num_points = size(D3_GLOBAL.calibration.point,1);
  case 2
    num_points = length(D3_GLOBAL.spatial_model.point) ;
end

D3_GLOBAL.current_point = D3_GLOBAL.current_point + 1 ;
if D3_GLOBAL.current_point <= num_points
  end_points = 0 ;
else
  end_points = 1 ;
  D3_GLOBAL.current_point = 1 ;
end

set(D3_GLOBAL.handles.point_select_popup,'value',D3_GLOBAL.current_point);


function [speedadj] = frame_cam_speedadj
global D3_GLOBAL

cam_offset(1) = fix(( D3_GLOBAL.trial_params.trial_start - D3_GLOBAL.trial_params.clip(1).start )*...
  D3_GLOBAL.trial_params.fvideo + .5);
cam_offset(2) = fix(( D3_GLOBAL.trial_params.trial_start - D3_GLOBAL.trial_params.clip(2).start )*...
  D3_GLOBAL.trial_params.fvideo + .5);

frame_cam(1) = D3_GLOBAL.current_frame + cam_offset(1);
frame_cam(2) = D3_GLOBAL.current_frame + cam_offset(2);

%playback_speed is not always 30
speed_factor(1) = D3_GLOBAL.internal.playback_speed / D3_GLOBAL.internal.cam_speed(1) ;
speed_factor(2) = D3_GLOBAL.internal.playback_speed / D3_GLOBAL.internal.cam_speed(2) ;

speedadj = frame_cam .* speed_factor ;


function load_video_frame(buffering)
global D3_GLOBAL
global running

if buffering
  buffer_length = 100;
else
  buffer_length = 1;
end

frame_cam_speedadj_array = frame_cam_speedadj;

current_frame = frame_cam_speedadj_array(D3_GLOBAL.camera);

if isfield(D3_GLOBAL, 'buffer')
  buffer_indx = find(D3_GLOBAL.buffer.frames == current_frame); %our image is inside the buffer
else
  buffer_indx = false;
end

if isfield(D3_GLOBAL, 'buffer') && (D3_GLOBAL.buffer.cam == D3_GLOBAL.camera) && ~isempty(buffer_indx)
  D3_GLOBAL.image(D3_GLOBAL.camera).c.cdata = D3_GLOBAL.buffer.video(:,:,:,buffer_indx);
else
  try
    if (datenum(version('-date')) >= datenum('3-September-2010'))
      obj = VideoReader(D3_GLOBAL.cam(D3_GLOBAL.camera).name);
    else
      obj = mmreader(D3_GLOBAL.cam(D3_GLOBAL.camera).name);
    end
    
    if obj.NumberOfFrames ~= 1 %a calibration with only one frame breaks the reading of the mmreader object
      if (D3_GLOBAL.current_frame + buffer_length) >= D3_GLOBAL.max_frames
        buffer_length = D3_GLOBAL.max_frames-D3_GLOBAL.current_frame+1;
      end
      
      D3_GLOBAL.buffer.cam = D3_GLOBAL.camera;
      D3_GLOBAL.buffer.frames = 0;
      D3_GLOBAL.buffer.video = 0;
      
      running = 1;
      D3_GLOBAL.buffer.video = read(obj, [current_frame current_frame+buffer_length-1]);
      running = 0;
      D3_GLOBAL.buffer.frames = current_frame:current_frame+buffer_length-1;
      
      %images = read(obj, [current_frame current_frame+10]);
      D3_GLOBAL.image(D3_GLOBAL.camera).c.cdata = D3_GLOBAL.buffer.video(:,:,:,1);
    end
  catch
    disp('No video file');
  end
end

%end_frames =1 if we are out of frames
function [end_frames] = advance_frame
global D3_GLOBAL

%we only advance if we are not calibrating
if get(D3_GLOBAL.handles.mode_popup,'value') == 1
  end_frames = 1;
  return
end

D3_GLOBAL.current_frame = D3_GLOBAL.current_frame + 1 ;
if D3_GLOBAL.current_frame <= D3_GLOBAL.max_frames
  end_frames = 0;
else
  D3_GLOBAL.current_frame = 1 ;
  end_frames = 1 ;
end

load_video_frame(true);


% --------------------------------------------------------------------
function varargout = point_select_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL
D3_GLOBAL.current_point = get(handles.point_select_popup,'value');
point_changed(handles);

%-----------------------------------------------------------------------
function point_changed(handles)
global D3_GLOBAL

typ = 2 ;
if ~isempty(D3_GLOBAL.spatial_model.point(D3_GLOBAL.current_point).stationary)
  if D3_GLOBAL.spatial_model.point(D3_GLOBAL.current_point).stationary == 1
    typ = 1 ;
  end
end
set(handles.point_type_popup,'value',typ);

cell_array = get(handles.point_color_popup,'string');
val = find(strcmp(cell_array,D3_GLOBAL.spatial_model.point(D3_GLOBAL.current_point).color));
if isempty(val)
  val = 1 ;
end
set(handles.point_color_popup,'value',val);




% --------------------------------------------------------------------
function varargout = point_type_popup_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

if get(gcbo,'value') == 1
  stationary = 1 ;
else
  stationary = 0 ;
end

D3_GLOBAL.spatial_model.point(D3_GLOBAL.current_point).stationary = stationary ;
update(handles);



% --------------------------------------------------------------------
function varargout = add_point_button_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = point_color_popup_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

cell_array = get(handles.point_color_popup,'string');
D3_GLOBAL.spatial_model.point(D3_GLOBAL.current_point).color =...
  cell_array{get(handles.point_color_popup,'value')};
update(handles);

% --------------------------------------------------------------------
function varargout = trial_video1_Callback(h, eventdata, handles, varargin)

load_video_file(handles,1);

% --------------------------------------------------------------------
function varargout = trial_video2_Callback(h, eventdata, handles, varargin)

load_video_file(handles,2);


function load_video_file(handles,cam)
global D3_GLOBAL

pn = './';

if ispref('d3_path','video') && ischar(getpref('d3_path','video')) && exist(getpref('d3_path','video'),'dir')
  pn = [getpref('d3_path','video') '\'];
else
  disp('Your paths variable points to a directory that no longer exists. Please update the paths.');
end

if isfield(D3_GLOBAL,'vid_dir') 
  if exist(D3_GLOBAL.vid_dir,'dir')
    pn = D3_GLOBAL.vid_dir;
  else
    disp('Could not find your video file.');
    D3_GLOBAL.vid_dir = '.\';
  end
else
  D3_GLOBAL.vid_dir = '.\';
end

pause(.1) %added because on external hard drive, it was prematurely exiting uigetfile without being called
[filename, pathname] = uigetfile( {'*.avi';'*.mp4';'*.*'},...
  ['Load Camera #' num2str(cam) ' video'],pn);
if isequal(filename,0) %cancelled
  return;
end

D3_GLOBAL.vid_dir = pathname;
D3_GLOBAL.cam(cam).name = [pathname filename];

if ~isempty(D3_GLOBAL.cam(1).name) && ~isempty(D3_GLOBAL.cam(2).name)
  indx = strfind(filename,'compressed');
  %if the filename has been compressed we assume it follows our naming
  %convention and construct the trial code
  if ~isempty(indx)
    trial_num = filename(indx-3:indx-2);
    D3_GLOBAL.tcode = [filename(1:11) trial_num];
    set(gcf,'Name',['3-d: ' D3_GLOBAL.tcode],'NumberTitle','off');
    set(handles.trialcode_edit,'string',D3_GLOBAL.tcode);
  else
    set(handles.trialcode_edit,'BackgroundColor',[1 48/255 48/255]);
  end
end

load_trial_video(handles,cam);
if cam == D3_GLOBAL.camera
  load_video_frame(0);
  update(handles);
end

% --------------------------------------------------------------------
% This is called when we first load a trial. If we don't have a video file we set stuff from the analysed data
function load_trial_video(handles,n)
global D3_GLOBAL

D3_GLOBAL.max_frames = round((D3_GLOBAL.trial_params.trial_end - D3_GLOBAL.trial_params.trial_start) *...
  D3_GLOBAL.trial_params.fvideo) + 1;%+1 because if we only had one frame...

set(handles.frame_slider,'min',1,'max',D3_GLOBAL.max_frames,'sliderstep',[2/D3_GLOBAL.max_frames 10/D3_GLOBAL.max_frames],...
  'value',1);
D3_GLOBAL.current_frame = 1 ;
frame_cam_speedadj_array = frame_cam_speedadj;

if exist(D3_GLOBAL.cam(n).name,'file')
  if (datenum(version('-date')) >= datenum('3-September-2010'))
    obj = VideoReader(D3_GLOBAL.cam(n).name);
  else
    obj = mmreader(D3_GLOBAL.cam(n).name);
  end
else
  disp('cant find video file');
end
try
  D3_GLOBAL.image(n).c.cdata = read(obj, frame_cam_speedadj_array(n));
catch
  disp('load_trial_video :No video');
end
set(handles.frame_edit,'string',num2str(D3_GLOBAL.current_frame));


function get_dlt
global D3_GLOBAL

num_cams = length(D3_GLOBAL.calibration.cam);
for n=1:num_cams,
  F = D3_GLOBAL.calibration.point ;
  L = D3_GLOBAL.calibration.cam(n).point ;
  %L(:,2) = 460 - L(:,2);
  [A, avgres] = dltfu(F,L);
  D3_GLOBAL.calibration.A(:,n) = A';
  D3_GLOBAL.calibration.avgres(:,n) = avgres';
end

%this is a check of accuracy
L1 = [D3_GLOBAL.calibration.cam(1).point  D3_GLOBAL.calibration.cam(2).point];
A = D3_GLOBAL.calibration.A ;
H1 = reconfu(A,L1);
err = D3_GLOBAL.calibration.point - H1(:,1:3)

space_err = mean(abs(err),1)

err_str = ['x : ' num2str(space_err(1)) ' y : ' num2str(space_err(2)) ' z : ' num2str(space_err(3))];

set(D3_GLOBAL.handles.dlt_display_edit,'string',err_str);


%this gives us back the reconstructed 3d
function get_3d
global D3_GLOBAL

all_str = get(D3_GLOBAL.handles.smoothing_popup,'string');
filt_len = str2double(all_str{get(D3_GLOBAL.handles.smoothing_popup,'value')});
smooth_camera_coords(filt_len);

A = D3_GLOBAL.calibration.A;

%%just for point one...
disp('Computing 3d for smoothened data');

for n = 1:length(D3_GLOBAL.rawdata.point)
  L = [D3_GLOBAL.rawdata.smoothened_point(n).cam(1).coordinate...
    D3_GLOBAL.rawdata.smoothened_point(n).cam(2).coordinate];
  disp('using smoothened cam coords');
  H = reconfu(A,L);
  
  D3_GLOBAL.reconstructed.point(n).pos = H(:,1:3);
end


% --------------------------------------------------------------------
function varargout = dlt_button_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

get_dlt ;



% --------------------------------------------------------------------
function varargout = tight_button_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

%D3_GLOBAL.remember_zoom = 0 ;
zoom off;
update(handles);






% --------------------------------------------------------------------
function varargout = play_button_Callback(h, eventdata, handles, varargin)
set(gcbo,'string','Stop');
play_movie;

function play_movie
global D3_GLOBAL

while get(D3_GLOBAL.handles.play_button,'value') == 1
  if D3_GLOBAL.current_frame == D3_GLOBAL.max_frames
    break;
  end
  
  D3_GLOBAL.current_frame = D3_GLOBAL.current_frame + 1 ;
  load_video_frame(true);
  update(D3_GLOBAL.handles);
  drawnow
end
set(D3_GLOBAL.handles.play_button,'value',0);
set(D3_GLOBAL.handles.play_button,'string','Play');

function [Mout] =image_manipulation(Min)
global D3_GLOBAL
if ndims(Min) == 3
  Min = rgb2gray(Min);
end;

%D3_GLOBAL.internal.quantization_level
if strcmp(D3_GLOBAL.internal.quantization_level, 'none')
  Mout = Min ;
else
  Mout = histeq(Min,str2double(D3_GLOBAL.internal.quantization_level));
end

%Mout = moving_average(Min);

function Mout = cross_corr_img(Min)
persistent Moldest

if isempty(Moldest)
  Moldest =  Min;
end

Mout = xcorr2(double(Min), double(Moldest));
Moldest = Min ;
Mout = histeq(Mout,6);


function Mout = moving_average(Min)
persistent counter imageHistory Mold
avg_len = 30 ;

if isempty(imageHistory)
  counter = 1;
  imageHistory(1).M = [];
end
if isempty(Mold)
  Mold = Min;
end

imageHistory(counter).M = Min ;
counter = counter + 1;
if counter > avg_len %buffer has been filled
  lala.M = Min;
  imageHistory(1:avg_len) = [imageHistory(2:avg_len) lala];
end

%averaged image
Mout = double(imageHistory(1).M);
for n=2:length(imageHistory)
  Mout = Mout + double(imageHistory(n).M);
end
Mout = uint8(Mout/n);


function Mout = difference_image(Min)
persistent Molder

if isempty(Molder)
  Molder = Min;
end

% for difference image
Mout = uint8((double(Min) - double(Molder) + 255.)/2. );
Molder = Min ;
Mout = histeq(Mout,6);



% --------------------------------------------------------------------
function varargout = reconstruct_button_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

get_3d;

axes(handles.axes_3d);
plot_3dreconstructed;

% --------------------------------------------------------------------
function plot_3dreconstructed
global D3_GLOBAL

for n =1:length(D3_GLOBAL.reconstructed.point)
  x = D3_GLOBAL.reconstructed.point(n).pos(:,1);
  z = D3_GLOBAL.reconstructed.point(n).pos(:,2);
  y = -D3_GLOBAL.reconstructed.point(n).pos(:,3);
  
  plot3(x,y,z,D3_GLOBAL.spatial_model.point(n).color);hold on; grid on
  plot3(x(1),y(1),z(1), [ 'o' D3_GLOBAL.spatial_model.point(n).color]);
end
hold off; xlabel('x'); ylabel('y')
axis equal


% --------------------------------------------------------------------
function varargout = quantization_popup_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

all_str = get(gcbo,'string');
D3_GLOBAL.internal.quantization_level = all_str{get(gcbo,'value')};
update(handles);


% --------------------------------------------------------------------
function varargout = smoothing_popup_Callback(h, eventdata, handles, varargin)

all_str = get(gcbo,'string');
filt_len = str2double(all_str{get(gcbo,'value')});
smooth_camera_coords(filt_len);
update(handles);


function smooth_camera_coords(filt_len)
%note that this does not take into consideration the ignored frames (and it ought to...)
global D3_GLOBAL

for n=1:length(D3_GLOBAL.rawdata.point)%cycle thru points
  
  len = size(D3_GLOBAL.rawdata.point(n).cam(1).coordinate,1);
  if filt_len == 0
    filt_indices = [];
  else
    filt_indices = 1:filt_len:len;
    if filt_indices(end) ~= len
      filt_indices(end+1) = len;
    end
  end
  y1 = D3_GLOBAL.rawdata.point(n).cam(1).coordinate(filt_indices,1);
  y2 = D3_GLOBAL.rawdata.point(n).cam(1).coordinate(filt_indices,2);
  x_sub = filt_indices;
  x = 1:len;
  
  if filt_len < 1
    D3_GLOBAL.rawdata.smoothened_point(n).cam(1).coordinate = D3_GLOBAL.rawdata.point(n).cam(1).coordinate ;
  else
    D3_GLOBAL.rawdata.smoothened_point(n).cam(1).coordinate = [spline(x_sub,y1,x)'  spline(x_sub,y2,x)'] ;
  end
  
  len = size(D3_GLOBAL.rawdata.point(n).cam(2).coordinate,1);
  y1 = D3_GLOBAL.rawdata.point(n).cam(2).coordinate(filt_indices,1);
  y2 = D3_GLOBAL.rawdata.point(n).cam(2).coordinate(filt_indices,2);
  x_sub = filt_indices;
  x = 1:len;
  
  if filt_len < 1
    D3_GLOBAL.rawdata.smoothened_point(n).cam(2).coordinate = D3_GLOBAL.rawdata.point(n).cam(2).coordinate ;
  else
    D3_GLOBAL.rawdata.smoothened_point(n).cam(2).coordinate = [spline(x_sub,y1,x)' spline(x_sub,y2,x)'] ;
  end
end


function [x] = cam_coord_smooth(xin,filt_len)

%hack....
if filt_len < 2
  x = xin;
  return ;
end

b = ones(1,filt_len)/filt_len;
a = 1;
x = filtfilt(b,a,xin);



% --------------------------------------------------------------------
function varargout = dlt_display_edit_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = fill_button_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

len = D3_GLOBAL.max_frames - D3_GLOBAL.current_frame + 1 ;

D3_GLOBAL.rawdata.point(D3_GLOBAL.current_point).cam(D3_GLOBAL.camera).coordinate(D3_GLOBAL.current_frame:D3_GLOBAL.current_frame + len-1,:) =...
  repmat([D3_GLOBAL.internal.x D3_GLOBAL.internal.y],len,1);

D3_GLOBAL.current_frame = 1;

load_video_frame(false);
update(handles);


% --------------------------------------------------------------------
function varargout = plot_trajectory_check_Callback(h, eventdata, handles, varargin)
update(handles);



% --------------------------------------------------------------------
function varargout = plot_blow_button_Callback(h, eventdata, handles, varargin)

figure ;
plot_3dreconstructed ;



% --------------------------------------------------------------------
function varargout = cam1_speed_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

prompt={'Enter new camera 1 speed'};
def={num2str(D3_GLOBAL.internal.cam_speed(1))};
dlgTitle='Camera 1 speed';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);

if isempty(answer)
  return;
end
D3_GLOBAL.internal.cam_speed(1) = str2double(answer{1}) ;

% --------------------------------------------------------------------
function varargout = cam2_speed_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

prompt={'Enter new camera 2 speed'};
def={num2str(D3_GLOBAL.internal.cam_speed(2))};
dlgTitle='Camera 2 speed';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);

if isempty(answer)
  return;
end
D3_GLOBAL.internal.cam_speed(2) = str2double(answer{1}) ;




% --------------------------------------------------------------------
function varargout = zoomon_button_Callback(h, eventdata, handles, varargin)

zoom on;



% --------------------------------------------------------------------
function varargout = trialcode_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.tcode = get(handles.trialcode_edit,'string');
set(gcf,'Name',['3-d: ' D3_GLOBAL.tcode],'NumberTitle','off');
set(handles.trialcode_edit,'BackgroundColor',[1 1 1]);


% --------------------------------------------------------------------
function varargout = trial_start_frame_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.trial_params.trial_start = str2double(get(gcbo,'string')) / D3_GLOBAL.trial_params.fvideo  ;
set(handles.trial_start_edit,'string',num2str(D3_GLOBAL.trial_params.trial_start));
D3_GLOBAL.d3_analysed.startframe =  round(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo);
set(handles.db_frame_text,'string',[ num2str(D3_GLOBAL.d3_analysed.startframe) ' , ' num2str(D3_GLOBAL.d3_analysed.endframe)]);

load_trial_video(handles,1)
load_trial_video(handles,2)
update(handles);


% --------------------------------------------------------------------
function varargout = trial_end_frame_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.trial_params.trial_end = str2double(get(gcbo,'string')) / D3_GLOBAL.trial_params.fvideo ;
set(handles.trial_end_edit,'string',num2str(D3_GLOBAL.trial_params.trial_end));
D3_GLOBAL.d3_analysed.endframe =  round(D3_GLOBAL.trial_params.trial_end * D3_GLOBAL.trial_params.fvideo);
set(handles.db_frame_text,'string',[ num2str(D3_GLOBAL.d3_analysed.startframe) ' , ' num2str(D3_GLOBAL.d3_analysed.endframe)]);

load_trial_video(handles,1)
load_trial_video(handles,2)
update(handles);


% --------------------------------------------------------------------
function varargout = clip_start_c1_frame_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.trial_params.clip(1).start = str2double(get(gcbo,'string')) / D3_GLOBAL.trial_params.fvideo  ; %video clip 1 starts at....
set(handles.clip_start_c1_edit,'string',num2str(D3_GLOBAL.trial_params.clip(1).start))
set(handles.trial_start_edit,'string',num2str(D3_GLOBAL.trial_params.clip(1).start));%this means that we'll get all of the clip #1
set(handles.clip_start_c2_edit,'string',num2str(D3_GLOBAL.trial_params.clip(1).start));%this means that we'll get all of the clip #2
set(handles.trial_start_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.clip(1).start*D3_GLOBAL.trial_params.fvideo)));%this means that we'll get all of the clip #1
set(handles.clip_start_c2_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.clip(1).start*D3_GLOBAL.trial_params.fvideo)));%this means that we'll get all of the clip #2

D3_GLOBAL.trial_params.trial_start = str2double(get(handles.trial_start_edit,'string')) ;
D3_GLOBAL.trial_params.clip(2).start = str2double(get(handles.clip_start_c2_edit,'string'));

D3_GLOBAL.d3_analysed.startframe =  round(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo);
D3_GLOBAL.d3_analysed.endframe =  round(D3_GLOBAL.trial_params.trial_end * D3_GLOBAL.trial_params.fvideo);
set(handles.db_frame_text,'string',[ num2str(D3_GLOBAL.d3_analysed.startframe) ' , ' num2str(D3_GLOBAL.d3_analysed.endframe)]);

load_trial_video(handles,1)
load_trial_video(handles,2)
update(handles);


% --------------------------------------------------------------------
function varargout = clip_start_c2_frame_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.trial_params.clip(2).start = str2double(get(gcbo,'string')) /D3_GLOBAL.trial_params.fvideo ;
set(handles.clip_start_c2_edit,'string',num2str(D3_GLOBAL.trial_params.clip(2).start))
existingtrialstartval = str2double(get(handles.trial_start_edit,'string')) ;
if D3_GLOBAL.trial_params.clip(2).start > existingtrialstartval
  set(handles.trial_start_edit,'string',num2str(D3_GLOBAL.trial_params.clip(2).start));%this means that we'll get all of the clip #2
  set(handles.trial_start_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.clip(2).start*D3_GLOBAL.trial_params.fvideo)));%this means that we'll get all of the clip #1
end
D3_GLOBAL.trial_params.trial_start = str2double(get(handles.trial_start_edit,'string')) ;



D3_GLOBAL.d3_analysed.startframe =  round(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo);
D3_GLOBAL.d3_analysed.endframe =  round(D3_GLOBAL.trial_params.trial_end * D3_GLOBAL.trial_params.fvideo);
set(handles.db_frame_text,'string',[ num2str(D3_GLOBAL.d3_analysed.startframe) ' , ' num2str(D3_GLOBAL.d3_analysed.endframe)]);

load_trial_video(handles,1)
load_trial_video(handles,2)
update(handles);


% --------------------------------------------------------------------
function varargout = clip_start_c1_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.trial_params.clip(1).start = str2double(get(gcbo,'string')) ; %video clip 1 starts at....
set(handles.clip_start_c1_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.clip(1).start * D3_GLOBAL.trial_params.fvideo)));

%existingtrialstartval = str2double(get(handles.trial_start_edit,'string')) ;
set(handles.trial_start_edit,'string',num2str(D3_GLOBAL.trial_params.clip(1).start));%this means that we'll get all of the clip #1
set(handles.clip_start_c2_edit,'string',num2str(D3_GLOBAL.trial_params.clip(1).start));%this means that we'll get all of the clip #2

D3_GLOBAL.trial_params.trial_start = str2double(get(handles.trial_start_edit,'string')) ;
D3_GLOBAL.trial_params.clip(2).start = str2double(get(handles.clip_start_c2_edit,'string'));

set(handles.trial_start_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo)));
set(handles.clip_start_c2_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.clip(2).start * D3_GLOBAL.trial_params.fvideo)));

D3_GLOBAL.d3_analysed.startframe =  round(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo);
D3_GLOBAL.d3_analysed.endframe =  round(D3_GLOBAL.trial_params.trial_end * D3_GLOBAL.trial_params.fvideo);
set(handles.db_frame_text,'string',[ num2str(D3_GLOBAL.d3_analysed.startframe) ' , ' num2str(D3_GLOBAL.d3_analysed.endframe)]);

load_trial_video(handles,1)
load_trial_video(handles,2)
update(handles);

% --------------------------------------------------------------------
function varargout = clip_start_c2_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.trial_params.clip(2).start = str2double(get(gcbo,'string')) ;
set(handles.clip_start_c2_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.clip(2).start * D3_GLOBAL.trial_params.fvideo)));
existingtrialstartval = str2double(get(handles.trial_start_edit,'string')) ;
if D3_GLOBAL.trial_params.clip(2).start > existingtrialstartval
  set(handles.trial_start_edit,'string',num2str(D3_GLOBAL.trial_params.clip(2).start));%this means that we'll get all of the clip #2
  set(handles.trial_start_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.clip(2).start * D3_GLOBAL.trial_params.fvideo)));
end
D3_GLOBAL.trial_params.trial_start = str2double(get(handles.trial_start_edit,'string')) ;
D3_GLOBAL.d3_analysed.startframe =  round(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo);
D3_GLOBAL.d3_analysed.endframe =  round(D3_GLOBAL.trial_params.trial_end * D3_GLOBAL.trial_params.fvideo);
set(handles.db_frame_text,'string',[ num2str(D3_GLOBAL.d3_analysed.startframe) ' , ' num2str(D3_GLOBAL.d3_analysed.endframe)]);

load_trial_video(handles,1)
load_trial_video(handles,2)
update(handles);

% --------------------------------------------------------------------
function varargout = trial_start_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.trial_params.trial_start = str2double(get(gcbo,'string')) ;
set(handles.trial_start_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo)));
set(handles.db_frame_text,'string',[ num2str(D3_GLOBAL.d3_analysed.startframe) ' , ' num2str(D3_GLOBAL.d3_analysed.endframe)]);

load_trial_video(handles,1)
load_trial_video(handles,2)
update(handles);

% --------------------------------------------------------------------
function varargout = trial_end_edit_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

D3_GLOBAL.trial_params.trial_end = str2double(get(gcbo,'string'));
set(handles.trial_end_frame_edit,'string',num2str(round(D3_GLOBAL.trial_params.trial_end * D3_GLOBAL.trial_params.fvideo)));
set(handles.db_frame_text,'string',[ num2str(D3_GLOBAL.d3_analysed.startframe) ' , ' num2str(D3_GLOBAL.d3_analysed.endframe)]);

load_trial_video(handles,1)
load_trial_video(handles,2)
update(handles);



% --------------------------------------------------------------------
function frame_rate_Callback(hObject, eventdata, handles)
global D3_GLOBAL
D3_GLOBAL.trial_params.fvideo = str2double(get(hObject,'String'));
set_time_frame_parameters(handles);
set(handles.frame_rate,'BackgroundColor',[1 1 1]);


function set_time_frame_parameters(handles)
global D3_GLOBAL

%fixing the time textboxes and variables...
D3_GLOBAL.trial_params.trial_start = str2double(get(handles.trial_start_frame_edit,'string')) / D3_GLOBAL.trial_params.fvideo  ;
set(handles.trial_start_edit,'string',num2str(D3_GLOBAL.trial_params.trial_start));
D3_GLOBAL.trial_params.trial_end = str2double(get(handles.trial_end_frame_edit,'string')) / D3_GLOBAL.trial_params.fvideo ;
set(handles.trial_end_edit,'string',num2str(D3_GLOBAL.trial_params.trial_end));

D3_GLOBAL.trial_params.clip(1).start = str2double(get(handles.clip_start_c1_frame_edit,'string')) / D3_GLOBAL.trial_params.fvideo;
D3_GLOBAL.trial_params.clip(2).start = str2double(get(handles.clip_start_c2_frame_edit,'string')) / D3_GLOBAL.trial_params.fvideo;
set(handles.clip_start_c1_edit,'string',num2str(D3_GLOBAL.trial_params.clip(1).start));
set(handles.clip_start_c2_edit,'string',num2str(D3_GLOBAL.trial_params.clip(2).start));

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function frame_rate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function varargout = export_db_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

mat_export_Callback(h, eventdata, handles, varargin); %just to make sure
tcode = get(handles.trialcode_edit,'string');
tstart = D3_GLOBAL.trial_params.trial_start ;
startframe = round(tstart * D3_GLOBAL.trial_params.fvideo) ; %not the start of the data but the start of the video data, according to the db
import_segment(tcode, startframe);


% --------------------------------------------------------------------
% Export in the new and improved d3 format
function varargout = mat_export_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

if ~ispref('d3_path','analyzed_path')
  pathname = uigetdir(pwd, 'Locate mat file export folder');
  setpref('d3_path','analyzed_path',[pathname]);
end
mat_file_path = getpref('d3_path','analyzed_path');

if isfield(D3_GLOBAL.internal,'file_name') && ...
    exist(fileparts(D3_GLOBAL.internal.file_name),'dir')
  pn=[fileparts(D3_GLOBAL.internal.file_name) '\'];
elseif exist(mat_file_path,'dir')
  pn = [mat_file_path '\'];
else
  disp('Path does not exist.  Update your analyzed video file dirctory.');
  pn = '.\';
end

[filename, pathname] = uiputfile( [pn D3_GLOBAL.tcode '_' num2str(D3_GLOBAL.d3_analysed.startframe) '_d3.mat'],'Save trial as');
if filename == 0
  disp('Save cancelled.')
  return
end

fn = [pathname filename];
saved = save_d3_mat_file(fn, D3_GLOBAL);
if ~saved
  errordlg('mat file not saved','Error');
end

% this function follows the point order as given in the spatial model
% --------------------------------------------------------------------
function export_as_motus
global D3_GLOBAL

old_dir = pwd ;


if ~ispref('d3_path','analyzed_path')
  [pathname] = uigetdir(pwd, 'Locate folder to export motus files to');
  setpref('d3_path','analyzed_path',[pathname]);
end
pn = getpref('d3_path','analyzed_path');

if isfield(D3_GLOBAL.internal,'file_name')
  proposed_fname = D3_GLOBAL.internal.file_name(1:end-3) ;
  slash_locations = strfind(proposed_fname,'\');
  if ~isempty(slash_locations)
    proposed_fname = proposed_fname(slash_locations(end):end);
  end
else
  proposed_fname = 'motus_data';
end

first_frame_stamp = abs(fix(D3_GLOBAL.trial_params.trial_start * D3_GLOBAL.trial_params.fvideo)) ;
proposed_fname = [proposed_fname '_' num2str(first_frame_stamp)]

try
  cd(pn);
catch
  disp('Path does not exist.  Update your analyzed video file dirctory.');
end;
[filename, pathname] = uiputfile( [proposed_fname '.3ld'],'Save position data in motus (text) format');
cd(old_dir);
if filename == 0
  return
end

if length(filename) > 3
  if filename(length(filename)-3:length(filename)) ~= '.3ld'
    filename = [filename '.3ld'];
  end
else
  %no extension ?
  filename = [filename '.3ld'];
end


for j=1:length(D3_GLOBAL.reconstructed.point)
  data_matrix(1:size(D3_GLOBAL.reconstructed.point(j).pos,1),(4*(j-1)+1):(4*j)) =...
    [D3_GLOBAL.reconstructed.point(j).pos zeros(size(D3_GLOBAL.reconstructed.point(j).pos,1),1)];
end

%2005.04.21 : kghose
fname = [pathname filename];
f = fopen(fname,'w');
for N=1:size(data_matrix,1)
  fprintf(f,'%f',data_matrix(N,1));
  for M=2:size(data_matrix,2),
    fprintf(f,', %f',data_matrix(N,M));
  end
  fprintf(f,'\n');
end
fclose(f);


% --------------------------------------------------------------------
function varargout = export_motus_Callback(h, eventdata, handles, varargin)
export_as_motus ;


% --- Executes on button press in Auto_Track_pushbutton.
function Auto_Track_pushbutton_Callback(hObject, eventdata, handles)
% read there a start frame
Ref_Frame = str2double(get(handles.Auto_Track_Reference_Frame_edit,'string'));
End_Frame = str2double(get(handles.Auto_Tracking_End_Frame_edit,'string'));
set(handles.Auto_Track_Stop_pushbutton,'Enable','on');
set(handles.Auto_Track_Stop_pushbutton,'UserData',0);
Auto_Track (handles, Ref_Frame, End_Frame);



% --- Executes on button press in Auto_Track_Stop_pushbutton.
function Auto_Track_Stop_pushbutton_Callback(hObject, eventdata, handles)
set(hObject,'UserData',1);



% --- Executes during object creation, after setting all properties.
function Auto_Track_Reference_Frame_edit_CreateFcn(hObject, eventdata, handles)
if ispc
  set(hObject,'BackgroundColor','white');
else
  set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Auto_Track_Reference_Frame_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function Auto_Tracking_End_Frame_edit_CreateFcn(hObject, eventdata, handles)
if ispc
  set(hObject,'BackgroundColor','white');
else
  set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Auto_Tracking_End_Frame_edit_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of Auto_Tracking_End_Frame_edit as text
%        str2double(get(hObject,'String')) returns contents of Auto_Tracking_End_Frame_edit as a double
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%%%%%%  Auto Tracking
%--------------------------------------------------------------------------
function handles = Auto_Track (handles, Ref_Frame_Ind, End_Frame)
global D3_GLOBAL
%%% Potential additions
% 1. Stop, Resume, Cancel options ('DONE July 16 2007')
% 2. A temp buffer in case of tracking is cancelled (or paritial arease for sellected intervals).
% 3. A check is needed for frame index accuracy
% 3. Optional smoothing, contrast threshold options.
% 4. Predictive tracking (Kalman Filtering etc.) for multiple objects
% 5. Potential solutions for wing related bias in center of mass
% computation
% 6. Clustering of multiple groups for preventing jumps when two objects
% are close

n = D3_GLOBAL.camera;

file = D3_GLOBAL.cam(n).name;
if isempty(file)
  disp('No camera file')
  set(handles.Auto_Track_Stop_pushbutton,'UserData',0,'Enable','off');
  return;
end;

% finding the current frame index
cam_offset(n) = fix(( D3_GLOBAL.trial_params.trial_start - D3_GLOBAL.trial_params.clip(n).start )*...
  D3_GLOBAL.trial_params.fvideo + .5);

frame_cam(n) = D3_GLOBAL.current_frame + cam_offset(n);

%playback_speed is not always 30
speed_factor(n) = D3_GLOBAL.internal.playback_speed / D3_GLOBAL.internal.cam_speed(n) ;

frame_cam_speedadj = frame_cam(n) .* speed_factor(n) ;
beg_frame = frame_cam_speedadj;

if End_Frame > D3_GLOBAL.max_frames
  disp('End Frame Should Be Less Than Max Frames, End Frame Changed To Max Frames')
  End_Frame = D3_GLOBAL.max_frames;
end;

N = beg_frame + End_Frame - D3_GLOBAL.current_frame;
if beg_frame > N
  disp('End Frame Should Be Larger Than Current Slider Value')
  set(handles.Auto_Track_Stop_pushbutton,'Enable','off');
  return;
end;

colormap gray

if (datenum(version('-date')) >= datenum('3-September-2010'))
  obj = VideoReader(file);
else
  obj = mmreader(file);
end

a.cdata = read(obj, cam_offset(n)+Ref_Frame_Ind + 1);

if ndims(a.cdata) == 3
  Ref_Frame = rgb2gray(a.cdata);
else
  Ref_Frame = a.cdata;
end;
Ref_Frame = double(image_manipulation(Ref_Frame));


a = D3_GLOBAL.image(n).c;
if ndims(a.cdata) == 3
  curr_frame = rgb2gray(a.cdata);
else
  curr_frame = a.cdata;
end;
curr_frame = double(image_manipulation(curr_frame));
qwe = (curr_frame-Ref_Frame);%20;
thr_mult = str2double(get(handles.auto_track_thresh,'String'));
thr = thr_mult*std((qwe(:))); %15; %20
qwe = qwe > thr;
imagesc(curr_frame);

hold on
[Y, X] = find(qwe==1); plot(X,Y,'.r')
[x, y] = ginput(1);
hold off
%D3_GLOBAL.internal.x = x;%we need this since this fun returns corners of a voxel that we clicked (we think)
%D3_GLOBAL.internal.y = y;
tic
for k = beg_frame:N
  if get(handles.Auto_Track_Stop_pushbutton,'UserData')     %% Interupt check to stop tracking
    break
    %set(handles.Auto_Track_Stop_pushbutton,'UserData',0,'Enable','off');
    %return;
  end;
  a = D3_GLOBAL.image(n).c;
  if ndims(a.cdata) == 3
    B = rgb2gray(a.cdata);
  else
    B = a.cdata;
  end;
  B = double(image_manipulation(B));
  if get(handles.rel_ref_frame,'value')
    Ref_Frame_Ind = str2double(get(handles.Auto_Track_Reference_Frame_edit,'string'));
    
    rrff=D3_GLOBAL.current_frame + cam_offset(n) + Ref_Frame_Ind;
    
    if isfield(D3_GLOBAL, 'buffer')
      buffer_indx = find(D3_GLOBAL.buffer.frames == rrff); %our image is inside the buffer
    else
      buffer_indx = false;
    end
    
    if buffer_indx
      ref.cdata = D3_GLOBAL.buffer.video(:,:,:,buffer_indx);
    else
      ref.cdata = read(obj,rrff);
    end
    
    if ndims(ref.cdata) == 3
      Ref_Frame = rgb2gray(ref.cdata);
    else
      Ref_Frame = ref.cdata;
    end;
    Ref_Frame = double(image_manipulation(Ref_Frame));
    
  end
  qwe = (B-Ref_Frame)>thr;
  
  [Y X] = find(qwe==1); S = [X Y];
  dist = sqrt(sum((S - repmat([x y],length(Y),1)).^2,2));
  indx = find(dist<10);
  %set(h,'CData',B)%imagesc(B);
  hold on;
  if isempty(indx)
    disp('Sorry can''t continue :( --> Tracking Failed !!! ');
    t = toc;
    disp(['Ellapsed time is: ' num2str(t) ' seconds. Frames/Second: ' num2str((k-beg_frame)/t)]);
    update(handles);
    return;
  end;
  x = mean(X(indx));
  y = mean(Y(indx));
  
  %     coord(k,:) = [x y];
  
  D3_GLOBAL.internal.x = x;%we need this since this fun returns corners of a voxel that we clicked (we think)
  D3_GLOBAL.internal.y = y;
  
  %plot(x, y,'*');%,'erasemode','xor'); %plot(coord(beg_frame:end,1),coord(beg_frame:end,2),'w');
  drawnow;
  hold off;
  
  get_next_frame;
end;
set(handles.Auto_Track_Stop_pushbutton,'UserData',0,'Enable','off');
t = toc;
disp(['Ellapsed time is: ' num2str(t) ' seconds. Frames/Second: ' num2str((N-beg_frame)/t)]);


% --- Executes on button press in load_stationary_points_button.
function load_stationary_points_button_Callback(hObject, eventdata, handles)
global D3_GLOBAL;

return_code = load_stationary_points;
if return_code == 1
  update(D3_GLOBAL.handles);
end


% --- Executes during object creation, after setting all properties.
function cam_fname_edit_CreateFcn(hObject, eventdata, handles)



function cam_fname_edit_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)


function key_press_handler(hObject)
handles = guidata(gcbo);
global D3_GLOBAL


key=get(hObject,'CurrentKey');

switch key
  case 'f'
    if strcmp(D3_GLOBAL.last_key_press,'control')
      %might need some additional error checking
      fill_button_Callback('','', handles,'');
    end
end

D3_GLOBAL.last_key_press = key;


% --------------------------------------------------------------------
function menu_tools_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_ignore_segs_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_ignore_segs_cam1_Callback(hObject, eventdata, handles)

global D3_GLOBAL
if ~isfield(D3_GLOBAL,'ignore_segs_cam1')
  D3_GLOBAL.ignore_segs_cam1=[];
  D3_GLOBAL.ignore_segs_cam2=[];
end
if isempty(D3_GLOBAL.ignore_segs_cam1)
  igseg_str = '';
else
  igseg_str = mat2str( D3_GLOBAL.ignore_segs_cam1 );
end
answer = inputdlg( {'Enter Camera 1 ignore segments matrix: (format: clip1start clip1end; clip2start clip2end):'}, ...
  'Relative frame number range to ignore...', ...
  1, {igseg_str} );
if isempty(answer)
  % User hit Cancel; do nothing and return
  return
end
% Catch (and ignore) silly argument; note that it is not verified that
% given relative frame numbers lie within the
ignore_segs_cam = str2num(answer{1});
if (isempty(ignore_segs_cam) && ~isempty(answer{1}))...
    || (~isempty(ignore_segs_cam) ...
    && (size(ignore_segs_cam,2) ~= 2 || any(ignore_segs_cam(:) ~= fix(ignore_segs_cam(:)))))
  warndlg('Given ignore segments string is invalid; it will be ignored.', 'Invalid input');
  return
end

D3_GLOBAL.ignore_segs_cam1 = ignore_segs_cam;


% --------------------------------------------------------------------
function menu_ignore_segs_cam2_Callback(hObject, eventdata, handles)

global D3_GLOBAL
if ~isfield(D3_GLOBAL,'ignore_segs_cam2')
  D3_GLOBAL.ignore_segs_cam1=[];
  D3_GLOBAL.ignore_segs_cam2=[];
end
if isempty(D3_GLOBAL.ignore_segs_cam2)
  igseg_str = '';
else
  igseg_str = mat2str( D3_GLOBAL.ignore_segs_cam2 );
end
answer = inputdlg( {'Enter Camera 2 ignore segments matrix (format: clip1start clip1end; clip2start clip2end):'}, ...
  'Relative frame number range to ignore...', ...
  1, {igseg_str} );
if isempty(answer)
  % User hit Cancel; do nothing and return
  return
end
% Catch (and ignore) silly argument; note that it is not verified that
% given relative frame numbers lie within the
ignore_segs_cam = str2num(answer{1});
if (isempty(ignore_segs_cam) && ~isempty(answer{1}))... %if there is a value entered that wasn't converted to a num
    || (~isempty(ignore_segs_cam) ... %got something
    && (size(ignore_segs_cam,2) ~= 2 || ... %it's a column vector?
    any(ignore_segs_cam(:) ~= fix(ignore_segs_cam(:)))))
  warndlg('Given ignore segments string is invalid; it will be ignored.', 'Invalid input');
  return
end

D3_GLOBAL.ignore_segs_cam2 = ignore_segs_cam;


% --------------------------------------------------------------------
function manage_spatial_models_Callback(hObject, eventdata, handles)
waitfor(manage_spatial_models);



function auto_track_thresh_Callback(hObject, eventdata, handles)
set(hObject,'String',num2str(str2double(get(hObject,'String'))));


% --- Executes during object creation, after setting all properties.
function auto_track_thresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rel_ref_frame.
function rel_ref_frame_Callback(hObject, eventdata, handles)


% --- Executes on button press in show_point_names.
function show_point_names_Callback(hObject, eventdata, handles)
% hObject    handle to show_point_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_point_names
update(handles);