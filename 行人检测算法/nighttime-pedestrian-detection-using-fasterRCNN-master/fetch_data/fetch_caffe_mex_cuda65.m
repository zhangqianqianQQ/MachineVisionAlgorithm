
cur_dir = pwd;
cd(fileparts(mfilename('fullpath')));

try
    fprintf('Downloading caffe_mex...\n');
    options = weboptions('Timeout',Inf);
    websave('caffe_mex.zip','https://drive.google.com/uc?export=download&id=1yvit9mHOzTO31wMfbIqWkrtIvQ7gBa3B',options);

    fprintf('Unzipping...\n');
    unzip('caffe_mex.zip', '..');

    fprintf('Done.\n');
    delete('caffe_mex.zip');
catch
    fprintf('Error in downloading, please try links in README.md https://github.com/ShaoqingRen/faster_rcnn'); 
end

cd(cur_dir);
