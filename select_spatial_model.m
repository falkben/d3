function varargout = select_spatial_model(varargin)
% SELECT_SPATIAL_MODEL Application M-file for select_spatial_model.fig
%    FIG = SELECT_SPATIAL_MODEL launch select_spatial_model GUI.
%    SELECT_SPATIAL_MODEL('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 22-Mar-2004 19:29:16

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

    % code to load the list of available spatial models
    load_spatial_models(handles);

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
function varargout = model_select_popup_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = ok_button_Callback(h, eventdata, handles, varargin)
global D3_GLOBAL
load spatial_models;

D3_GLOBAL.spatial_model =...
    spatial_model(get(handles.model_select_popup,'value'));

for n =1:length(D3_GLOBAL.spatial_model.point)
    if isempty(D3_GLOBAL.spatial_model.point(n).color)
        D3_GLOBAL.spatial_model.point(n).color = 'w';
    end
end    

closereq




% --------------------------------------------------------------------
function varargout = cancel_button_Callback(h, eventdata, handles, varargin)
closereq


% looks for the mat file containing the calibration frames under the
% current directory name is spatial_models.mat
function load_spatial_models(handles)

load spatial_models

%set the popup list
names = {spatial_model(:).name};
set(handles.model_select_popup,'string',names);