function [FA_noisy, FA_d] = tensor_fitting_full(dwi_noisy, dwi_denoised, gradientDirections, numb0, Mask)
% testing denoising effects
%% b matrices computation
bacq = 2000;
[N1,N2,numDWI] = size(dwi_noisy);
bVal = bacq*ones(numDWI-numb0,1);
bVal = [zeros(numb0,1);bVal];

Gx = gradientDirections(:,1);
Gy = gradientDirections(:,2);
Gz = gradientDirections(:,3);

bMatrices(1,1,:) = Gx.^2;
bMatrices(1,2,:) = Gx.*Gy;
bMatrices(1,3,:) = Gx.*Gz;
bMatrices(2,1,:) = bMatrices(1,2,:);
bMatrices(2,2,:) = Gy.^2;
bMatrices(2,3,:) = Gy.*Gz;
bMatrices(3,1,:) = bMatrices(1,3,:);
bMatrices(3,2,:) = bMatrices(2,3,:);
bMatrices(3,3,:) = Gz.^2;
for i =1:numDWI
    bM(:,:,i) = bMatrices(:,:,i)*bVal(i);
end

% slice        = round(Ns/2);
% dwi_noisy    = squeeze(noisy_seq(:,:,slice,:));
% dwi_denoised = squeeze(denoised_seq(:,:,slice,:));

% Fitting noisy data
for curBval = bacq
    ind = [find(bVal==0);find(bVal==curBval)];
    bImages        = reshape(dwi_noisy(:,:,ind),[],numel(ind));
    bImages        = permute(bImages,[2,1]);
    [lambdas_n, eigenVectors_n, M0] = dtiLogLinear_LAM(bImages, bM(:,:,ind), 'S0_unknown', []);
    MD = squeeze(mean(lambdas_n,1));
    FA_noisy = sqrt(3/2)*sqrt((squeeze(lambdas_n(1,:,:,:,:))-MD).^2+(squeeze(lambdas_n(2,:,:,:,:))-MD).^2+(squeeze(lambdas_n(3,:,:,:,:))-MD).^2)./squeeze(sqrt(sum(lambdas_n.^2,1)));
    RGB_noisy(:,:,3) = FA_noisy.*reshape(abs(squeeze(eigenVectors_n(2,1,:,:))),size(FA_noisy));
    RGB_noisy(:,:,2) = FA_noisy.*reshape(abs(squeeze(eigenVectors_n(3,1,:,:))),size(FA_noisy));
    RGB_noisy(:,:,1) = FA_noisy.*reshape(abs(squeeze(eigenVectors_n(1,1,:,:))),size(FA_noisy));
    RGB_noisy(RGB_noisy>sqrt(3)/4) = sqrt(3)/4;
    RGB_noisy        = reshape(RGB_noisy/(sqrt(3)/4),[N1,N2,3]).*repmat(Mask,[1,1,3]);
%     figure,imagesc(RGB_noisy),axis image off, caxis([0,1]), title('Noisy data')
    
    FA_noisy = reshape(FA_noisy,N1,N2).*Mask;
%     figure,imagesc(FA_noisy),caxis([0,0.4]),colormap gray,axis image off
end

% Fitting denoised data
bImages = reshape(dwi_denoised(:,:,ind),[],numel(ind));
bImages = permute(bImages,[2,1]);
[lambdas_d, eigenVectors_d, M0] = dtiLogLinear_LAM(bImages, bM(:,:,ind), 'S0_unknown', []);
MD_d = squeeze(mean(lambdas_d,1));
FA_d = sqrt(3/2)*sqrt((squeeze(lambdas_d(1,:,:,:,:))-MD_d).^2+(squeeze(lambdas_d(2,:,:,:,:))-MD_d).^2+(squeeze(lambdas_d(3,:,:,:,:))-MD_d).^2)./squeeze(sqrt(sum(lambdas_d.^2,1)));
%     figure,imagesc(reshape(FA_d,N1,N2).*Mask),colormap gray, axis image off,title('Magnitude data denoising')
RGB_denoised(:,:,3) = FA_d.*reshape(abs(squeeze(eigenVectors_d(3,1,:,:))),size(FA_d));
RGB_denoised(:,:,2) = FA_d.*reshape(abs(squeeze(eigenVectors_d(2,1,:,:))),size(FA_d));
RGB_denoised(:,:,1) = FA_d.*reshape(abs(squeeze(eigenVectors_d(1,1,:,:))),size(FA_d));
RGB_denoised(RGB_denoised>sqrt(3)/4) = sqrt(3)/4;
RGB_denoised        = reshape(RGB_denoised/(sqrt(3)/4),[N1,N2,3]).*repmat(Mask,[1,1,3]);
%     figure,imagesc(RGB_denoised), axis image off, caxis([0,1]), title('Denoised with Joint Constraints')
FA_d = reshape(FA_d,N1,N2).*Mask;
%     figure,imagesc(FA_d),caxis([0,0.4]),colormap gray,axis image off,title('Denoised data')

end