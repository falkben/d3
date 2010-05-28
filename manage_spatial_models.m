function varargout = manage_spatial_models(varargin)
% MANAGE_SPATIAL_MODELS M-file for manage_spatial_models.fig
%      MANAGE_SPATIAL_MODELS, by itself, creates a new MANAGE_SPATIAL_MODELS or raises the existing
%      singleton*.
%
%      H = MANAGE_SPATIAL_MODELS returns the handle to a new MANAGE_SPATIAL_MODELS or the handle to
%      the existing singleton*.
%
%      MANAGE_SPATIAL_MODELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANAGE_SPATIAL_MODELS.M with the given input arguments.
%
%      MANAGE_SPATIAL_MODELS('Property','Value',...) creates a new MANAGE_SPATIAL_MODELS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manage_spatial_models_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manage_spatial_models_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manage_spatial_models

% Last Modified by GUIDE v2.5 28-May-2010 14:54:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manage_spatial_models_OpeningFcn, ...
                   'gui_OutputFcn',  @manage_spatial_models_OutputFcn, ...
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


% --- Executes just before manage_spatial_models is made visible.
function manage_spatial_models_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manage_spatial_models (see VARARGIN)

% Choose default command line output for manage_spatial_models
handles.output = hObject;

handles = initialize(handles);
update(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manage_spatial_models wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function handles = initialize(handles)

load spatial_models;
handles.spatial_model = spatial_model;

handles.current_model = 1;

function update(handles)
set(handles.points_listbox,'String',{handles.spatial_model(handles.current_model).point.name});
set(handles.name_listbox,'String',{handles.spatial_model.name});
set(handles.name_listbox,'Value',handles.current_model);


% --- Outputs from this function are returned to the command line.
function varargout = manage_spatial_models_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in name_listbox.
function name_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to name_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns name_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from name_listbox

handles.current_model = get(hObject,'Value');
update(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function name_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in points_listbox.
function points_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns points_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from points_listbox


% --- Executes during object creation, after setting all properties.
function points_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in up_pushbutton.
function up_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to up_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.current_model > 1
    top_model = handles.spatial_model(handles.current_model - 1);
    bottom_model = handles.spatial_model(handles.current_model);
    handles.spatial_model(handles.current_model - 1) = bottom_model;
    handles.spatial_model(handles.current_model) = top_model;
    
    handles.current_model = handles.current_model - 1;
    
    update(handles);
    guidata(hObject, handles);
end

% --- Executes on button press in down_pushbutton.
function down_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to down_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_model < length(handles.spatial_model)
    top_model = handles.spatial_model(handles.current_model);
    bottom_model = handles.spatial_model(handles.current_model + 1);
    handles.spatial_model(handles.current_model) = bottom_model;
    handles.spatial_model(handles.current_model + 1) = top_model;
    
    handles.current_model = handles.current_model + 1;
    
    update(handles);
    guidata(hObject, handles);
end


% --- Executes on button press in delete_pushbutton.
function delete_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to delete_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button = questdlg('Are you sure you want to delete the selected spatial model?',...
    'Delete Model','Yes','Cancel','Cancel');
    switch button
        case 'Cancel'
            return;
    end

if length(handles.spatial_model) > 1
    handles.spatial_model(handles.current_model) = [];
    handles.current_model = handles.current_model - 1;
    update(handles);
    guidata(hObject, handles);
end

% --- Executes on button press in edit_pushbutton.
function edit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load spatial_models;
indx = handles.current_model;
if ~isequal(spatial_model,handles.spatial_model)
    button = questdlg('Save changes to spatial models before editing?  All changes since last save will be lost'...
        ,'Save Changes');
    switch button
        case 'Yes'
            save_spatial_models(handles);
        case 'No'
            names = {spatial_model.name};
            indx = strmatch(handles.spatial_model(handles.current_model).name,names);
        case 'Cancel'
            return;
    end
end

waitfor(new_spatial_model(handles.spatial_model(handles.current_model),...
    indx));

load spatial_models;
handles.spatial_model = spatial_model;
handles.current_model = indx;

update(handles);
guidata(hObject, handles);

% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_spatial_models(handles);

function save_spatial_models(handles)
spatial_model = handles.spatial_model;
save('spatial_models.mat','spatial_model','-mat');


% --- Executes on button press in reload_pushbutton.
function reload_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to reload_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = initialize(handles);
update(handles);
guidata(hObject, handles);

