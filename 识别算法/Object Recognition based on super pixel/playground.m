
close all;


 % Required for parsing the labels and numbers. 
 files = dir('*.jpg');
 for file = files
     [row,col] = size(file);
     for i=1:row
         %fprintf("File name %s", file(i).name);
         NAME = file(i).name;
         IMG = imread(NAME);
         A = ComparisonWithReal(IMG,NAME);
     end
 end
 

% NAME = '000012.jpg';
% PATH_IMG = "Data/" + NAME;
% I_ORG = imread(PATH_IMG{1});
% I = im2double(I_ORG);
% 
% % 
% % boundingBox = { [206,97,351,270] ,[1,2,2,5], [26,27,51,70]};
% % [prec,reca] = evaluate(NAME,boundingBox, 0.5);
% 
% 
% [labels,numlabels] = getSPLabels(I,100,2,150);
% [result,pixCount] = findMeanColor(I,labels,numlabels);
% 
% Iclone = I;
% [rC,cC, ~] = size(I);
% 
% for r=1:rC
%     for c=1:cC
%         tmp = result{labels(r,c)+1};
%         Iclone(r,c,1) = tmp(1,1) / 256;
%         Iclone(r,c,2) = tmp(1,2) / 256;
%         Iclone(r,c,3) = tmp(1,3) / 256;
%     end
% end
% 
% imshowpair(I, Iclone, 'montage')