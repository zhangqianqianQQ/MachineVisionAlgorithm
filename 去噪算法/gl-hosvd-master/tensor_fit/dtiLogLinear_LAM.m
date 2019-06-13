function [lambdas, eigenVectors,M_0] = dtiLogLinear_LAM(bImages, bMatrices, flag, M0)

M = size(bImages,2);
N = size(bImages,3);
P = size(bImages,4);
B = size(bImages,1); % number of directions or number of directions+1

%% Configure linear equations
if strcmp(flag,'S0_unknown')
    diffusionWeightedImages = zeros(B,M,N,P);
    bMatrix = zeros(B,7);

    if length(size(bImages)) < 3
        for bIndex = 1:B
            diffusionWeightedImages(bIndex,:) = log(abs(squeeze(bImages(bIndex,:))));
            bMatrix(bIndex,:) = -[bMatrices(1,1,bIndex) bMatrices(2,2,bIndex) bMatrices(3,3,bIndex) 2*bMatrices(2,1,bIndex) 2*bMatrices(3,1,bIndex) 2*bMatrices(3,2,bIndex) -1];
        end
    end
%     diffusionWeightedImages(isnan(diffusionWeightedImages))=-1e16;
%     diffusionWeightedImages(isinf(diffusionWeightedImages))=-1e16;
    diffusionWeightedImages(isnan(diffusionWeightedImages))=eps;
    diffusionWeightedImages(isinf(diffusionWeightedImages))=eps;

    %% Permute diffusion tensors and calculate various meta-parameters
    lambdas = zeros(3,M,N,P);
    eigenVectors = zeros(3,3,M,N,P);
    %residualImage = zeros(M,N,P);
    M_0 = zeros(M,N,P);
    [Q,R] = qr(bMatrix,0);
    for mIndex = 1:M
        for nIndex = 1:N
            for pIndex = 1:P
                dValues = R\Q' *(diffusionWeightedImages(:,mIndex,nIndex,pIndex));
                [v,d] = eig([dValues(1),dValues(4),dValues(5);dValues(4),dValues(2),dValues(6);dValues(5),dValues(6),dValues(3)]);
                lambdas(:,mIndex,nIndex,pIndex) = flipud(sort(diag(d)));
                [temp,index1] = sort(diag(d));
                eigenVectors(:,:,mIndex,nIndex,pIndex) = v(:,flipud(index1));
                %residualImage(mIndex,nIndex,pIndex) = norm(bMatrix*dValues(:,mIndex,nIndex,pIndex) - diffusionWeightedImages(:,mIndex,nIndex,pIndex));
                M_0(mIndex,nIndex,pIndex) = exp(dValues(7));
            end
        end
    end
elseif strcmp(flag,'S0_known')
    diffusionWeightedImages = zeros(B,M,N,P);
    bMatrix = zeros(B,6);

    if length(size(bImages)) < 3
        for bIndex = 1:B
            diffusionWeightedImages(bIndex,:) = log(abs(squeeze(bImages(bIndex,:))));
            bMatrix(bIndex,:) = -[bMatrices(1,1,bIndex) bMatrices(2,2,bIndex) bMatrices(3,3,bIndex) 2*bMatrices(2,1,bIndex) 2*bMatrices(3,1,bIndex) 2*bMatrices(3,2,bIndex)];
        end
    end
    diffusionWeightedImages(isnan(diffusionWeightedImages))=-1e16;
    diffusionWeightedImages(isinf(diffusionWeightedImages))=-1e16;

    %% Permute diffusion tensors and calculate various meta-parameters
    lambdas = zeros(3,M,N,P);
    eigenVectors = zeros(3,3,M,N,P);
    %residualImage = zeros(M,N,P);
%     M_0 = zeros(M,N,P);
    [Q,R] = qr(bMatrix,0);
    for mIndex = 1:M
        for nIndex = 1:N
            for pIndex = 1:P
                dValues = R\Q' *(diffusionWeightedImages(:,mIndex,nIndex,pIndex));
                [v,d] = eig([dValues(1),dValues(4),dValues(5);dValues(4),dValues(2),dValues(6);dValues(5),dValues(6),dValues(3)]);
                lambdas(:,mIndex,nIndex,pIndex) = flipud(sort(diag(d)));
                [temp,index1] = sort(diag(d));
                eigenVectors(:,:,mIndex,nIndex,pIndex) = v(:,flipud(index1));
                %residualImage(mIndex,nIndex,pIndex) = norm(bMatrix*dValues(:,mIndex,nIndex,pIndex) - diffusionWeightedImages(:,mIndex,nIndex,pIndex));
            end
        end
    end
    M_0 = M0;
else
    error('Unrecognized flag')
end
return;