function varargout = new_spatial_model(varargin)
% NEW_SPATIAL_MODEL Application M-file for new_spatial_model.fig
%    FIG = NEW_SPATIAL_MODEL launch new_spatial_model GUI.
%    NEW_SPATIAL_MODEL('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 27-May-2010 15:50:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @new_spatial_model_OpeningFcn, ...
                   'gui_OutputFcn',  @new_spatial_model_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before new_spatial_model is made visible.
function new_spatial_model_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to new_spatial_model (see VARARGIN)

% Choose default command line output for new_spatial_model
handles.output = hObject;

if ~isempty(varargin) && isstruct(varargin{1})
    handles.spatial_model = varargin{1};
    handles.current_point = 1;
    handles.model_number = varargin{2};
    set(handles.figure1,'Name','Edit Spatial Model');
else
    handles = initialize(handles,1);
end

update(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes new_spatial_model wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = new_spatial_model_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function handles = initialize(handles,current_point)

if current_point == 1
    handles.spatial_model.name = [];
end
handles.spatial_model.point(current_point).name = [];
handles.spatial_model.point(current_point).color = 'b';
handles.spatial_model.point(current_point).stationary = 1;
handles.current_point = current_point;



function update(handles)
set(handles.model_edit,'String',handles.spatial_model.name);
set(handles.point_num_text,'String',[num2str(handles.current_point) ' / ' num2str(length(handles.spatial_model.point))]);
set(handles.name_edit,'String',handles.spatial_model.point(handles.current_point).name);

if handles.spatial_model.point(handles.current_point).stationary == 1
    value = 1;
else
    value = 2;
end
set(handles.type_select_popup,'Value',value);

cvalue = findstr('bgrcmykw',handles.spatial_model.point(handles.current_point).color);
set(handles.color_popupmenu,'Value',cvalue);


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


function model_edit_Callback(hObject, eventdata, handles)
% hObject    handle to model_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of model_edit as text
%        str2double(get(hObject,'String')) returns contents of model_edit as a double
name = get(hObject,'String');

load spatial_models;
names = {spatial_model.name};

if ~strcmp(name,names)
    handles.spatial_model.name = get(hObject,'String');
else
    set(hObject,'String','');
    disp('Spatial model already exists.');
end
guidata(hObject,handles);

function name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name_edit as text
%        str2double(get(hObject,'String')) returns contents of name_edit as a double

handles.spatial_model.point(handles.current_point).name = get(hObject,'String');
guidata(hObject,handles);

function varargout = type_select_popup_Callback(h, eventdata, handles, varargin)
value = get(h,'Value');

if value == 1
    stationary = 1;
else
    stationary = 0;
end

handles.spatial_model.point(handles.current_point).stationary = stationary;
guidata(h,handles);


% --- Executes on selection change in color_popupmenu.
function color_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to color_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color_popupmenu

colors = get(hObject,'String');
value = get(hObject,'Value');
handles.spatial_model.point(handles.current_point).color = colors{value};
guidata(hObject,handles);

% --- Executes on button press in next_pushbutton.
function next_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to next_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%can't move onto the next point until current point is filled out
if ~isempty(handles.spatial_model.point(handles.current_point).name)
    handles.current_point = handles.current_point + 1;
    if length(handles.spatial_model.point) < handles.current_point
        handles = initialize(handles,handles.current_point);
    end
    update(handles);
    guidata(hObject,handles);
end

% --- Executes on button press in prev_pushbutton.
function prev_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to prev_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_point > 1
    handles.current_point = handles.current_point - 1;
    update(handles);
    guidata(hObject,handles);
end

% --- Executes on button press in delete_pushbutton.
function delete_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to delete_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if length(handles.spatial_model.point) > 1
    
    handles.spatial_model.point(end) = [];
    
    if handles.current_point > length(handles.spatial_model.point)
        handles.current_point = handles.current_point - 1;
    end
    
    update(handles);
    guidata(hObject,handles);
    
end


% --------------------------------------------------------------------
function varargout = ok_button_Callback(h, eventdata, handles, varargin)

load spatial_models

if isfield(handles,'model_number')
    spatial_model(handles.model_number) = handles.spatial_model;
else
    %error checking
    names = {spatial_model.name};
    if ~isempty(find(strcmp(handles.spatial_model.name,names), 1)) || isempty(handles.spatial_model.name) || isempty(handles.spatial_model.point(end).name)
        return;
    end

    %add handles.spatial_model to spatial_models
    spatial_model(end+1)=handles.spatial_model;
end

%save spatial models
save('spatial_models.mat','spatial_model','-mat');

closereq;


% --------------------------------------------------------------------
function varargout = cancel_button_Callback(h, eventdata, handles, varargin)
closereq;




% --- Executes during object creation, after setting all properties.
function model_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function color_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



