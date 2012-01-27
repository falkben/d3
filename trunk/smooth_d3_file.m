%this function takes the full file name of a .d3 file and smooths the
%raw data points with the given filter length
function smooth_d3_file(fname,filt_len)

%can be called on a set of files:
% data_dir = 'F:/2008_Data/';
% pos_dir=[data_dir 'B52_Processed/'];
% pos_files=dir([pos_dir '2008.09.20.*.d3']);
% 
% for k=1:length(pos_files)
% smooth_d3_file([pos_dir pos_files(k).name],30);
% end


global D3_GLOBAL

if nargin < 1
  
  if ispref('d3_path','analyzed_path')
    mat_file_path = getpref('d3_path','analyzed_path');
  end
  if exist(mat_file_path,'dir')
    [filename, pathname] = uigetfile([mat_file_path '\*.d3'], 'Select a d3 analyzed file');
  else
    disp('Path does not exist.  Update your analyzed video file directory (in d3).');
    [filename, pathname] = uigetfile('*.d3', 'Select a d3 analyzed file');
  end
  if isequal(filename,0)
    return;
  else
    fname = [pathname filename];
  end
else
  pathname = [fileparts(fname) '/'];
end

load(fname,'-mat');

if nargin < 2
  filt_len = 45;
end

D3_GLOBAL = whole_trial;

smooth_camera_coords(filt_len);

A = D3_GLOBAL.calibration.A;

%%just for point one...
disp('Computing 3d for smoothened data');

%L = [D3_GLOBAL.rawdata.point(1).cam(1).coordinate D3_GLOBAL.rawdata.point(1).cam(2).coordinate];
for n = 1:length(D3_GLOBAL.rawdata.point)
  L = [D3_GLOBAL.rawdata.smoothened_point(n).cam(1).coordinate...
    D3_GLOBAL.rawdata.smoothened_point(n).cam(2).coordinate];
  disp('using smoothened cam coords');
  H = reconfu(A,L);
  
  D3_GLOBAL.reconstructed.point(n).pos = H(:,1:3);
end

fn=[pathname D3_GLOBAL.tcode '_' num2str(D3_GLOBAL.d3_analysed.startframe) '_d3_smooth.mat'];

save_d3_mat_file(fn, D3_GLOBAL);



function save_d3_mat_file(fn, D3_GLOBAL)

tcode = D3_GLOBAL.tcode;
startframe = D3_GLOBAL.d3_analysed.startframe;

d3_analysed = D3_GLOBAL.d3_analysed;
d3_analysed.trialcode = tcode;
d3_analysed.fvideo = D3_GLOBAL.trial_params.fvideo;
if isfield('D3_GLOBAL','ignore_segs_cam1') && isfield('D3_GLOBAL','ignore_segs_cam2')
  d3_analysed.ignore_segs = [D3_GLOBAL.ignore_segs_cam1; D3_GLOBAL.ignore_segs_cam2];
end

for n = 1:length(D3_GLOBAL.spatial_model.point)
  d3_analysed.object(n).name = D3_GLOBAL.spatial_model.point(n).name ;
  d3_analysed.object(n).video = [D3_GLOBAL.reconstructed.point(n).pos(:,1) ...
    -D3_GLOBAL.reconstructed.point(n).pos(:,3) ...
    D3_GLOBAL.reconstructed.point(n).pos(:,2)] ;
end

save(fn,'d3_analysed','-V6');
disp(['Saved ' tcode '_' num2str(startframe) '_d3.mat to: ' fn]);



function smooth_camera_coords(filt_len)
global D3_GLOBAL

for n=1:length(D3_GLOBAL.rawdata.point)%cycle thru points
  %     D3_GLOBAL.rawdata.smoothened_point(n).cam(1).coordinate =...
  %         cam_coord_smooth(D3_GLOBAL.rawdata.point(n).cam(1).coordinate,filt_len);
  %     D3_GLOBAL.rawdata.smoothened_point(n).cam(2).coordinate =...
  %         cam_coord_smooth(D3_GLOBAL.rawdata.point(n).cam(2).coordinate,filt_len);
  
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