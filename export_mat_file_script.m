function export_mat_file_script

    pathname = uigetdir(pwd, 'Locate .d3 analyzed files for _d3.mat file export');
    files = dir([pathname '\*.d3']);

    for k=1:length(files)
        d3_file = files(k);
        load_d3_file(pathname, d3_file.name);
    end

end

function load_d3_file(pathname, filename)
    load([pathname '\' filename],'-MAT');
    D3_GLOBAL = whole_trial;
    
    tcode = D3_GLOBAL.tcode;
    startframe = D3_GLOBAL.d3_analysed.startframe;
    
    d3_analysed = D3_GLOBAL.d3_analysed;
    d3_analysed.trialcode = tcode;
    d3_analysed.fvideo = D3_GLOBAL.trial_params.fvideo;
    
    for n = 1:length(D3_GLOBAL.spatial_model.point)
        d3_analysed.object(n).name = D3_GLOBAL.spatial_model.point(n).name ;
        d3_analysed.object(n).video = [D3_GLOBAL.reconstructed.point(n).pos(:,1) ...
            -D3_GLOBAL.reconstructed.point(n).pos(:,3) ...
            D3_GLOBAL.reconstructed.point(n).pos(:,2)] ;
    end
    
    fn = [pathname '\' tcode '_' num2str(startframe) '_d3.mat'];
    
    save(fn,'d3_analysed','-V6');
    disp(['Saved ' tcode '_' num2str(startframe) '_d3.mat to: ' pathname]);
end