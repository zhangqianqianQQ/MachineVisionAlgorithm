function OutputName = Recognition(TestImage, m, A, Eigenfaces)
%-------------Project the selected test image and all of the training
%images into Eigenfaces space. Compare the Euclidean distances between them and find the
%  index of image who gets minmum Euclidean distances.
ProjectedImages = [];
Train_Number = size(A,2);
for i = 1 : Train_Number
    temp = Eigenfaces' * A(:,i); % Projection of centered images into facespace
    ProjectedImages = [ProjectedImages temp]; 
end

%-------------Project the test image you selected into Eigenfaces space-------------
InputImage = imread(TestImage);
temp = InputImage(:,:,1);

[irow icol] = size(temp);
InImage = reshape(temp',irow*icol,1);
Difference = double(InImage)-m; 
Projected_TestImage = Eigenfaces'*Difference; % Test image feature vector

%----------------------- Calculate Euclidean distances and find the
%  index of image of minmum Euclidean distances-------------------- 
Euc_dist = [];
for i = 1 : Train_Number
    q = ProjectedImages(:,i);
    temp = ( norm( Projected_TestImage - q ) )^2;
    Euc_dist = [Euc_dist temp];
end

[Euc_dist_min , Recognized_index] = min(Euc_dist);
OutputName = strcat(int2str(Recognized_index),'.jpg');
