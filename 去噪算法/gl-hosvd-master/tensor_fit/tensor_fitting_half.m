function [error1,error2,error_v_noisy,error_v_denoised, FA_noisy, FA_denoised, RGB_noisy, RGB_denoised] = tensor_fitting_half(dwi_noisy, dwi_denoised, gradientDirections, numb0, Mask)
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

%% splitting into half-spheres
Gx    = gradientDirections(:,1);
indp  = find(Gx>0);
indn  = find(Gx<0);
ind0  = find(Gx==0);
len0  = length(ind0); % how many x=0 frames, need to split
spli  = round(len0/2);% where to split the Gx=0 frames
ind_r = [indp;ind0(1:spli)];
if len0 > 1
    ind_l = [indn;ind0(spli+1:end)];
else
    ind_l = [indn;ind0];
end


dwi_noisy_r = dwi_noisy(:,:,ind_r);
dwi_noisy_l = dwi_noisy(:,:,ind_l);
dwi_denoised_r = dwi_denoised(:,:,ind_r);
dwi_denoised_l = dwi_denoised(:,:,ind_l);
bM_r = bM(:,:,ind_r);
bM_l = bM(:,:,ind_l);

%%
% Fitting noisy data --- right half
bImages        = reshape(dwi_noisy_r,[],numel(ind_r));
bImages        = permute(bImages,[2,1]);
[lambdas_nr, eigenVectors_nr, M0] = dtiLogLinear_LAM(bImages, bM_r, 'S0_unknown', []);
MD = squeeze(mean(lambdas_nr,1));
FA_noisy = sqrt(3/2)*sqrt((squeeze(lambdas_nr(1,:,:,:,:))-MD).^2+(squeeze(lambdas_nr(2,:,:,:,:))-MD).^2+(squeeze(lambdas_nr(3,:,:,:,:))-MD).^2)./squeeze(sqrt(sum(lambdas_nr.^2,1)));
RGB_noisy(:,:,3) = FA_noisy.*reshape(abs(squeeze(eigenVectors_nr(3,1,:,:))),size(FA_noisy));
RGB_noisy(:,:,2) = FA_noisy.*reshape(abs(squeeze(eigenVectors_nr(1,1,:,:))),size(FA_noisy));
RGB_noisy(:,:,1) = FA_noisy.*reshape(abs(squeeze(eigenVectors_nr(2,1,:,:))),size(FA_noisy));
RGB_noisy(RGB_noisy>sqrt(3)/4) = sqrt(3)/4;
% RGB_noisy        = reshape(RGB_noisy/(sqrt(3)/4),[N1,N2,3]).*repmat(Mask,[1,1,3]);

% Fitting noisy data --- left half
bImages        = reshape(dwi_noisy_l,[],numel(ind_l));
bImages        = permute(bImages,[2,1]);
[lambdas_nl, eigenVectors_nl, M0] = dtiLogLinear_LAM(bImages, bM_l, 'S0_unknown', []);
MD = squeeze(mean(lambdas_nl,1));
FA_noisy = sqrt(3/2)*sqrt((squeeze(lambdas_nl(1,:,:,:,:))-MD).^2+(squeeze(lambdas_nl(2,:,:,:,:))-MD).^2+(squeeze(lambdas_nl(3,:,:,:,:))-MD).^2)./squeeze(sqrt(sum(lambdas_nl.^2,1)));
RGB_noisy(:,:,3) = FA_noisy.*reshape(abs(squeeze(eigenVectors_nl(3,1,:,:))),size(FA_noisy));
RGB_noisy(:,:,2) = FA_noisy.*reshape(abs(squeeze(eigenVectors_nl(1,1,:,:))),size(FA_noisy));
RGB_noisy(:,:,1) = FA_noisy.*reshape(abs(squeeze(eigenVectors_nl(2,1,:,:))),size(FA_noisy));
RGB_noisy(RGB_noisy>sqrt(3)/4) = sqrt(3)/4;
% RGB_noisy        = reshape(RGB_noisy/(sqrt(3)/4),[N1,N2,3]).*repmat(Mask,[1,1,3]);
%     figure,imagesc(RGB_noisy),axis image off, caxis([0,1]), title('Noisy data')

tensors_noisy_r    = zeros(3,3,N1*N2);
tensors_noisy_l    = zeros(3,3,N1*N2);
for vols = 1:N1*N2
	tensors_noisy_r(:,:,vols) = eigenVectors_nr(:,:,vols)*diag(lambdas_nr(:,vols))*(eigenVectors_nr(:,:,vols))';
end

for vols = 1:N1*N2
	tensors_noisy_l(:,:,vols) = eigenVectors_nl(:,:,vols)*diag(lambdas_nl(:,vols))*(eigenVectors_nl(:,:,vols))';
end

indis = find(Mask(:)>0);
tensors_noisy_r = tensors_noisy_r(:,:,indis);
tensors_noisy_l = tensors_noisy_l(:,:,indis);
error1 = 0; % difference between right and left hemisphere (noisy)
error_v_noisy = zeros(numel(indis),1);
for vols = 1:numel(indis)
    temp = norm(logm(tensors_noisy_r(:,:,vols)) - logm(tensors_noisy_l(:,:,vols)),'fro');
    error_v_noisy(vols) = temp;
	error1 = error1 + temp;
end
error1 = error1/length(Mask(Mask));
%%
% Fitting denoised data --- right half
bImages = reshape(dwi_denoised_r,[],numel(ind_r));
bImages = permute(bImages,[2,1]);
[lambdas_dr, eigenVectors_dr, M0] = dtiLogLinear_LAM(bImages, bM_r, 'S0_unknown', []);
MD_d = squeeze(mean(lambdas_dr,1));
FA_d = sqrt(3/2)*sqrt((squeeze(lambdas_dr(1,:,:,:,:))-MD_d).^2+(squeeze(lambdas_dr(2,:,:,:,:))-MD_d).^2+(squeeze(lambdas_dr(3,:,:,:,:))-MD_d).^2)./squeeze(sqrt(sum(lambdas_dr.^2,1)));
%     figure,imagesc(reshape(FA_d,N1,N2).*Mask),colormap gray, axis image off,title('Magnitude data denoising')
RGB_denoised(:,:,3) = FA_d.*reshape(abs(squeeze(eigenVectors_dr(3,1,:,:))),size(FA_d));
RGB_denoised(:,:,2) = FA_d.*reshape(abs(squeeze(eigenVectors_dr(1,1,:,:))),size(FA_d));
RGB_denoised(:,:,1) = FA_d.*reshape(abs(squeeze(eigenVectors_dr(2,1,:,:))),size(FA_d));
RGB_denoised(RGB_denoised>sqrt(3)/4) = sqrt(3)/4;
% RGB_denoised        = reshape(RGB_denoised/(sqrt(3)/4),[N1,N2,3]).*repmat(Mask,[1,1,3]);
% FA_d = reshape(FA_d,N1,N2).*Mask;

% Fitting denoised data --- left half
bImages = reshape(dwi_denoised_l,[],numel(ind_l));
bImages = permute(bImages,[2,1]);
[lambdas_dl, eigenVectors_dl, M0] = dtiLogLinear_LAM(bImages, bM_l, 'S0_unknown', []);
MD_d = squeeze(mean(lambdas_dl,1));
FA_d = sqrt(3/2)*sqrt((squeeze(lambdas_dl(1,:,:,:,:))-MD_d).^2+(squeeze(lambdas_dl(2,:,:,:,:))-MD_d).^2+(squeeze(lambdas_dl(3,:,:,:,:))-MD_d).^2)./squeeze(sqrt(sum(lambdas_dl.^2,1)));
%     figure,imagesc(reshape(FA_d,N1,N2).*Mask),colormap gray, axis image off,title('Magnitude data denoising')
RGB_denoised(:,:,3) = FA_d.*reshape(abs(squeeze(eigenVectors_dl(3,1,:,:))),size(FA_d));
RGB_denoised(:,:,2) = FA_d.*reshape(abs(squeeze(eigenVectors_dl(1,1,:,:))),size(FA_d));
RGB_denoised(:,:,1) = FA_d.*reshape(abs(squeeze(eigenVectors_dl(2,1,:,:))),size(FA_d));
RGB_denoised(RGB_denoised>sqrt(3)/4) = sqrt(3)/4;


tensors_denoised_r = zeros(3,3,N1*N2);
tensors_denoised_l = zeros(3,3,N1*N2);
for vols = 1:N1*N2
	tensors_denoised_r(:,:,vols) = eigenVectors_dr(:,:,vols)*diag(lambdas_dr(:,vols))*(eigenVectors_dr(:,:,vols))';
end

for vols = 1:N1*N2
	tensors_denoised_l(:,:,vols) = eigenVectors_dl(:,:,vols)*diag(lambdas_dl(:,vols))*(eigenVectors_dl(:,:,vols))';
end

tensors_denoised_r = tensors_denoised_r(:,:,indis);
tensors_denoised_l = tensors_denoised_l(:,:,indis);
error2 = 0; % difference between right and left hemisphere for denoised data
error_v_denoised = zeros(numel(indis),1);

for vols = 1:numel(indis)
    temp = norm(logm(tensors_denoised_r(:,:,vols)) - logm(tensors_denoised_l(:,:,vols)),'fro');
    error_v_denoised(vols) = temp;
	error2 = error2 + temp;
end
error2 = error2/length(Mask(Mask));

FA_noisy     = reshape(FA_noisy,N1,N2).*Mask;
FA_denoised  = reshape(FA_d,N1,N2).*Mask;
RGB_noisy    = reshape(RGB_noisy/(sqrt(3)/4),[N1,N2,3]).*repmat(Mask,[1,1,3]);
RGB_denoised = reshape(RGB_denoised/(sqrt(3)/4),[N1,N2,3]).*repmat(Mask,[1,1,3]);
end