% - This function is intended for image pre-processing
% - The function has five input arguments:-
% - FileName: the name of the input image.
% - PathName: the path of the input image.
% - Threshold: is set by default, you can change it

function BW=PreProcessing_General(FileName,Threshold)
%==========================================================================
% - This is to check whether the user needs to use automatic Thresholding; 
% - or he may need to change the default value.
if nargin==1
    Threshold=0.35;
end
%==========================================================================
% - This is to read the input image.
global NROWS
global NCOLS
IN_IMG=imread(FileName);
NROWS=size(IN_IMG,1);
NCOLS=size(IN_IMG,2);
%==========================================================================
% - This is to apply image enhacement , waiting for control input from
% - the user.

% - This is to define the window size.

W_Size=3;
IN_IMG=medfilt2(IN_IMG,[W_Size W_Size]);

background = imopen(IN_IMG,strel('disk',3));
IN_IMG = IN_IMG + background;

%==========================================================================
% - In case you need to show the output after applying median filter
% - uncomment this part
% figure;imshow(IN_IMG);
% set(title('Median Filter'),'color','b');
%==========================================================================
% - This is to apply Otsu's method thresholding
% - Global image threshold using Otsu's method
% Threshold = graythresh(IN_IMG);
figure; imshow(IN_IMG,[]);
BW=im2bw(IN_IMG,Threshold);
% figure; imshow(BW,[]); pause;
BW = imcomplement(BW);
% figure; imshow(BW,[]); pause;
% SE = strel('disk',3);
% BW = imclose(BW,SE);
% figure; imshow(BW,[]); pause;
BW = imfill(BW,'holes');
% figure; imshow(BW,[]); pause;
SE2 = strel('disk',3);
BW = imopen(BW,SE2);
% figure; imshow(BW,[]); pause;
% BW = imclearborder(BW);
% figure; imshow(BW,[]); pause;

%==========================================================================
% - To display the output after applying Otsu (uncomment this part) ,
% - save the image in Alg_Output folder
% figure;imshow(BW);impixelinfo;
% set(title('Image Threshold'),'color','b');
%==========================================================================
[~,name,~] = fileparts(FileName);
imwrite(BW,['./Results/Step1_PreProcess/' name '_Pre.jpg'],'jpg');
%==========================================================================
end