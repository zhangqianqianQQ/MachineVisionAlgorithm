function V = PCA_FilterBank(InImg, PatchSize, NumFilters) 

ImgZ = length(InImg);
MaxSamples = 100000;
NumRSamples = min(ImgZ, MaxSamples); 
RandIdx = randperm(ImgZ);
RandIdx = RandIdx(1:NumRSamples);

%% Learning PCA filters (V)
NumChls = size(InImg{1},3);
Rx = zeros(NumChls*PatchSize^2,NumChls*PatchSize^2);

for i = RandIdx %1:ImgZ
    im = im2col_mean_removal(InImg{i},[PatchSize PatchSize]); % collect all the patches of the ith image in a matrix, and perform patch mean removal
    Rx = Rx + im*im'; % sum of all the input images' covariance matrix
end
Rx = Rx/(NumRSamples*size(im,2));
[E D] = eig(Rx);
[~, ind] = sort(diag(D),'descend');
V = E(:,ind(1:NumFilters));  % principal eigenvectors 



 



