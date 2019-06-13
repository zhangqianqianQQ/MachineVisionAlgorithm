function [Recognized_index filename] = Recognition(Test_image, Mean, A, eigenfaces)


ProjectedImages = [];
Train_Number = size(eigenfaces,2);
for i = 1 : Train_Number
    temp = eigenfaces'*A(:,i); 
    ProjectedImages = [ProjectedImages temp]; 
end

% Extract the PCA features from test image

temp = Test_image;

[irow icol] = size(temp);
InImage = reshape(temp',irow*icol,1);
Difference = double(InImage)-Mean; 
ProjectedTestImage = eigenfaces'*Difference; 

% Calculate Euclidean distances 
% Test image is supposed to have minimum distance with its corresponding
% image in the training database.

dist = [];
for i = 1 : Train_Number
    q = ProjectedImages(:,i);
    temp = ( norm( ProjectedTestImage - q ) )^2;
    dist = [dist temp];
end

[dist_min , Recognized_index] = min(dist);

 filename=sprintf('s%d.1.tif', Recognized_index);
   disp(['matched image is ',filename]);
  
  
subplot(1,2,1); imshow(Test_image);
title('Test Image');
subplot(1,2,2); imshow(filename);
title('Matched Image')
  

end

