function save_d3_mat_file(fn, D3_GLOBAL)

tcode = D3_GLOBAL.tcode;
startframe = D3_GLOBAL.d3_analysed.startframe;

d3_analysed = D3_GLOBAL.d3_analysed;
d3_analysed.trialcode = tcode;
d3_analysed.fvideo = D3_GLOBAL.trial_params.fvideo;
d3_analysed.ignore_segs = [D3_GLOBAL.ignore_segs_cam1; D3_GLOBAL.ignore_segs_cam2];

for n = 1:length(D3_GLOBAL.spatial_model.point)
    d3_analysed.object(n).name = D3_GLOBAL.spatial_model.point(n).name ;
    d3_analysed.object(n).video = [D3_GLOBAL.reconstructed.point(n).pos(:,1) ...
    -D3_GLOBAL.reconstructed.point(n).pos(:,3) ...
    D3_GLOBAL.reconstructed.point(n).pos(:,2)] ;
end

save(fn,'d3_analysed','-V6');
disp(['Saved ' tcode '_' num2str(startframe) '_d3.mat to: ' fn]);