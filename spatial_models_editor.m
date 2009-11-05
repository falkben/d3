%load spatial model
[file, path] = uigetfile('*.mat','Load a spatial model');
load([path file]);

% display all the spatial model names
disp(['Number of spatial models: ', num2str(length(spatial_model))]);
for y = 1:length(spatial_model)
    disp([num2str(y) ': ' spatial_model(1,y).name]);
end

% remove typo field of statonary from all points in spatial model (should
% be stationary)
 for y = 1:length(spatial_model)
     if isfield(spatial_model(1,y).point(1,1), 'statonary')
         spatial_model(1,y).point = rmfield(spatial_model(1,y).point, 'statonary');
     end
 end

model = 35;
spatial_model(1,model).name='25 Point Calibration Frame';
for x=1:25
   spatial_model(1,model).point(1,x).stationary = 1;
   spatial_model(1,model).point(1,x).name = ['point ' num2str(x)];
   spatial_model(1,model).point(1,x).color = 'r';
end

% save('spatial_models.mat', 'spatial_model');

