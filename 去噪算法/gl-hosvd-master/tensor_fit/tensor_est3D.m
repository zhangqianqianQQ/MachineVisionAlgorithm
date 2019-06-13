function [FA, RGB, tensors] = tensor_est3D(dwis,gradientDirections,bVals,bacq)
% dwis: 3D+diffusion encodings (4D)
% gradientDirections: diffusion encoding gradients
% bVals: b values for each 3D vol
% bacq: the shell for tensor fitting
% display,exp_label,thres not utilized for current version

[N1,N2,N3,NumDWI] = size(dwis);
Gx   = gradientDirections(:,1);
Gy   = gradientDirections(:,2);
Gz   = gradientDirections(:,3);
bVal = bVals;

bMatrices(1,1,:) = Gx.^2;
bMatrices(1,2,:) = Gx.*Gy;
bMatrices(1,3,:) = Gx.*Gz;
bMatrices(2,1,:) = bMatrices(1,2,:);
bMatrices(2,2,:) = Gy.^2;
bMatrices(2,3,:) = Gy.*Gz;
bMatrices(3,1,:) = bMatrices(1,3,:);
bMatrices(3,2,:) = bMatrices(2,3,:);
bMatrices(3,3,:) = Gz.^2;
for i =1:length(Gx)
    bM(:,:,i) = bMatrices(:,:,i)*bVal(i);
end

% % ----- Extract the mask ----- %
% if ~exist(['Mask_' exp_label '.mat'],'file')
%     Mask    = zeros(N1,N2);
%     temp    = dwis(:,:,2);
%     loc1    = temp>thres;
%     Mask(loc1)   = 1;
%     Mask         = logical(Mask);
%     figure(99),imagesc(Mask),colormap gray,axis image off
%     for i = 1:15
%         rect = floor(getrect(figure(99)));
%         Mask(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3)) = 1;
%         figure(99),imagesc(Mask),colormap gray, axis image off,
%     %     refresh(figure(1))
%     %     [x, y] = getpts(ax)
%     end
%     save(['Mask_' exp_label '.mat'],'Mask');
% else
%     load(['Mask_' exp_label '.mat'],'Mask');
% end
% Mask(:,1)   = 0;
% Mask(:,end) = 0;
RGB = zeros(N1,N2,3,N3);
for curBval = bacq
    ind = [find(bVal==0);find(bVal==curBval)];
    bImages      = permute([reshape(dwis(:,:,:,ind),[],numel(ind))],[2,1]);
    [lambdas, eigenVectors, M0] = dtiLogLinear_LAM(bImages, bM(:,:,ind),'S0_unknown',[]);
    MD = squeeze(mean(lambdas,1));
    FA = sqrt(3/2)*sqrt((squeeze(lambdas(1,:,:,:,:))-MD).^2+(squeeze(lambdas(2,:,:,:,:))-MD).^2+(squeeze(lambdas(3,:,:,:,:))-MD).^2)./squeeze(sqrt(sum(lambdas.^2,1)));
    RGB(:,:,3,:) = reshape(FA.*reshape(abs(squeeze(eigenVectors(3,1,:,:))),size(FA)),N1,N2,1,N3);
    RGB(:,:,1,:) = reshape(FA.*reshape(abs(squeeze(eigenVectors(1,1,:,:))),size(FA)),N1,N2,1,N3);
    RGB(:,:,2,:) = reshape(FA.*reshape(abs(squeeze(eigenVectors(2,1,:,:))),size(FA)),N1,N2,1,N3);
    RGB(RGB>sqrt(3)/4) = sqrt(3)/4;
    RGB          = RGB/(sqrt(3)/4); %.*repmat(Mask,[1,1,3]);
    FA           = reshape(FA,N1,N2,1,N3);
%     FA    = FA.*Mask;
end

% getting the tensors
tensors   = zeros(3,3,N1*N2*N3);
for vols  = 1:N1*N2*N3
	tensors(:,:,vols) = eigenVectors(:,:,vols)*diag(lambdas(:,vols))*(eigenVectors(:,:,vols))';
end

% if display
%     figure,imagesc(FA),colormap gray,axis image off,caxis([0,0.8])
% %     figure,imagesc(RGB),axis image off,caxis([0,1])
% end