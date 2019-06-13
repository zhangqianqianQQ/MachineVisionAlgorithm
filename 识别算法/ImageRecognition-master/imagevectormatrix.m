function T= imagevectormatrix( Train_Number)
% CREATES THE IMAGE VECTOR MATRIX OF SIZE row*colxTrain_Number from the given set of
% images.

T = [];
for i = 1 : Train_Number
    
    filename=sprintf('s%d.1.tif', i);
   disp(['Reading image ',filename]);
    
    img = imread(filename);
    %img = rgb2gray(img);
    
    [irow icol] = size(img);
   
    temp = reshape(img',irow*icol,1);   % Reshaping 2D images into 1D image vectors
    T = [T temp]; % 'T' grows after each turn                    
end