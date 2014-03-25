function return_code = load_stationary_points
global D3_GLOBAL

return_code = 0;

if ~isfield(D3_GLOBAL, 'spatial_model')
    disp('Spatial model not loaded for current trial.')
    return;
elseif ~isfield(D3_GLOBAL, 'calibration')
    disp('Calibration not loaded for current trial.')
    return;
elseif isempty(D3_GLOBAL.max_frames)
    disp('Load your raw video first.')
    return;
elseif D3_GLOBAL.max_frames == 2127
    button = questdlg('Warning: Trial length has not been edited.','Trial length needs editing','Proceed','Cancel','Cancel');
    if strcmp(button,'Cancel')
        return;
    end
end

if ispref('d3_path','analyzed_path')
    [pn] = getpref('d3_path','analyzed_path');
else
    pn = './';
end

cdir = pwd;
try
    cd(pn);
catch
    disp('Cannot find your analyzed files directory.  Please check your paths.');
end;
[filename, pathname] = uigetfile( '*.d3','Load trial');
cd(cdir);
if ~isstr(filename)
    return;
end

load([pathname filename],'-MAT');

if ~strcmp([whole_trial.spatial_model.point(:).name],[D3_GLOBAL.spatial_model.point(:).name])...
    || ~strcmp([whole_trial.spatial_model.point(:).color],[D3_GLOBAL.spatial_model.point(:).color])...
    || ~isequal([whole_trial.spatial_model.point(:).stationary],[D3_GLOBAL.spatial_model.point(:).stationary])
    disp('Spatial models not compatible.');
    
    disp(['attempted: ' whole_trial.spatial_model.name]);
    disp(['yours:     ' D3_GLOBAL.spatial_model.name]);
    
    return;
end

for n = 1:length(whole_trial.spatial_model.point)
    if whole_trial.spatial_model.point(n).stationary == 1
        for c = 1:2
            for xy = 1:2
                D3_GLOBAL.rawdata.point(n).cam(c).coordinate(1:D3_GLOBAL.max_frames,xy) = whole_trial.rawdata.point(n).cam(c).coordinate(1,xy);
            end
        end
    end
end

return_code = 1;