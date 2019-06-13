clear all;clc;
pathname = uigetdir(cd,'选择打开文件夹');
if pathname == 0
    msgbox('您没有正确选择文件夹');
    return;
end
load('.\models\AcfInriaDetector.mat');
% load('E:\MatlabProject\code3.2.0\models\AcfCaltechDetector.mat');
% load('E:\MatlabProject\code3.2.0\models\det_ing.mat');
%load('D:\Program Files\MATLAB\R2012b\bin\toolbox\detector\models\AcfCaltechdetector.mat');
%load('D:\Program Files\MATLAB\R2012b\bin\code3.2.0\models\my_detector.mat');
% 可以打开几乎所有的图像类型，哈哈……全了……
filesbmp=ls(strcat(pathname,'\*.bmp')); 
filesjpg=ls(strcat(pathname,'\*.jpg'));
filesjpeg=ls(strcat(pathname,'\*.jpeg'));
filesgif=ls(strcat(pathname,'\*.gif')); 
filestif=ls(strcat(pathname,'\*.tif'));
filespng=ls(strcat(pathname,'\*.png'));
files=[cellstr(filesbmp);cellstr(filesjpg);...
    cellstr(filesjpeg);cellstr(filesgif);...
    cellstr(filestif);cellstr(filespng)];
len=length(files);
flag=[];
% 开始批量处理图像，转换格式
for ii=1:len
    if strcmp(cell2mat(files(ii)),'')
        continue;
    end
    Filesname{ii}=strcat(pathname,'\',files(ii));
    page{ii}=imread(cell2mat(Filesname{ii}));
    tic; bbs = acfDetect(page{ii}, detector);toc;
    [PATHSTR,NAME,EXT] = fileparts(Filesname{ii}{1});
    Filesname2{ii} = strcat(pathname, '\', NAME, '.txt');
    bbs8 = fix(bbs);
%     fid=fopen(Filesname2{ii}, 'w+');
%     len2 = length(bbs8(:,1));
%     bb = 123;
%     for jj = 1:len2
%     fprintf(fid, '%d %d %d %d %d\n', bbs8(jj, 1:5));
%     %count = fwrite(fid, bbs8(jj), 'int');
%     end
%     sta = fclose(fid);
    figure(1); im(page{ii}); 
    bbApply('draw',bbs);
    pause;
%     if length(size(page{ii}))==3 %图像为彩色RGB，进行转换
%         page1{ii}=rgb2gray(page{ii});
%         flag=[flag ii]; %用于存储被处理图像的在数组举证中的索引
%     end   
end
% 批量保存转换后的图片 
% for ii=1:length(flag)
%     fname_temp=cell2mat(Filesname{flag(ii)});
%     dot=strfind(fname_temp,'.');
%     fname_temp=fname_temp(1:dot(end)-1);
%     FileName=strcat(fname_temp,'彩色TO灰度.jpg');
%     imwrite(page1{flag(ii)},FileName );
% end