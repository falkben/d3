%loads a directory full of d3 files and saves the _d3.mat files in the new
%format
function export_mat_file_script

    pathname = uigetdir(pwd, 'Locate .d3 analyzed files for _d3.mat file export');
    files = dir([pathname '\*.d3']);

    for k=1:length(files)
        d3_file = files(k);
        [fn, D3_GLOBAL] = load_d3_file(pathname, d3_file.name);
        save_d3_mat_file(fn, D3_GLOBAL);
    end

end

%returns the filename and the D3_Global from the loaded d3 file
function [fn, D3_GLOBAL] = load_d3_file(pathname, filename)
    load([pathname '\' filename],'-MAT');
    D3_GLOBAL = whole_trial;
    
    fn = [pathname '\' D3_GLOBAL.tcode '_' num2str(D3_GLOBAL.d3_analysed.startframe) '_d3.mat'];
end