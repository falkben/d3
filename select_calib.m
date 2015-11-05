% finished
function varargout = select_calib(varargin)
% SELECT_CALIB Application M-file for select_calib.fig
%    FIG = SELECT_CALIB launch select_calib GUI.
%    SELECT_CALIB('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 22-Mar-2004 18:49:53

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

    % code to load the list of available calibration frames
    load_calibration_frames(handles);
    
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


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = ok_button_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

load calibration_frames;

D3_GLOBAL.calibration.object_name =...
    calibration(get(handles.object_popup,'value')).object_name;
D3_GLOBAL.calibration.point =...
    calibration(get(handles.object_popup,'value')).point;

varargout{1} = 1;
closereq

% --------------------------------------------------------------------
function varargout = object_popup_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = cancel_button_Callback(h, eventdata, handles, varargin)
varargout{1} = 0;
closereq;


% looks for the mat file containing the calibration frames under the
% current directory name is calibration_frames.mat
function load_calibration_frames(handles)

load calibration_frames

%set the popup list
names = {calibration(:).object_name};
set(handles.object_popup,'string',names);

% --------------------------------------------------------------------
function varargout = cam1_button_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

load_calibration_video(1);


% --------------------------------------------------------------------
function varargout = cam2_button_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL

load_calibration_video(2);


function load_calibration_video(cam)
global D3_GLOBAL

old_dir = pwd ;

if isfield(D3_GLOBAL,'vid_dir') && ~isnumeric(D3_GLOBAL.vid_dir) && (exist(D3_GLOBAL.vid_dir,'dir') ~= 0)
    cd(D3_GLOBAL.vid_dir);
end

[filename, pathname] = uigetfile( {'*.avi;*.mp4;*.png;*.jpg';'*.*'},...
  ['Load Camera #', num2str(cam), ' calibration']);
if (filename == 0)
    return;
end

D3_GLOBAL.vid_dir = pathname;
cd(old_dir);

[~,~,extension]=fileparts(filename);
if strcmpi(extension,'.avi') || strcmpi(extension,'.mp4')
  if (datenum(version('-date')) >= datenum('3-September-2010'))
    obj = VideoReader([pathname '/' filename]);
  else
    obj = mmreader([pathname '/' filename]);
  end
  D3_GLOBAL.calibration.image(cam).c.cdata = read(obj,1);
elseif strcmpi(extension,'.jpg') || strcmpi(extension,'.png')
  D3_GLOBAL.calibration.image(cam).c.cdata = imread([pathname '/' filename]);
else
  disp('could not load calibration image/video');
end


% M = aviread([pathname '/' filename],1);
% D3_GLOBAL.calibration.image(1).c = M ;