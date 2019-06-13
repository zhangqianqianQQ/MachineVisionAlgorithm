function [L] = classify(Model,X)

Weights = [];
Bs = [];
alpha = Model.alpha;
for i = 1:size(Model,1)
    Weights = vertcat(Weights,Model(i).Weights);
    Bs = vertcat(Bs,Model(i).Bs);
end
size(Weights)
[X] =  LoadImages(X);

[L] = SVMclassify(X,Weights,Bs,alpha);

end

function [Feat] =  LoadImages(data)
    Feat = [];
    for i = 1:size(data,1)
        
        image = reshape(data(i,:),[32,32,3]);
        image = imresize(image,2);
        feat = extract_feature(image);
        Feat = horzcat(Feat,feat);
    end
    Feat = Feat';
end

function [L] = SVMclassify(X,Weights,Bs,alpha)
sig = 1e-1;
    Xee = [];
    for s = 1:length(alpha)
        Xee = horzcat(Xee, double(X(:,alpha(s))));
    end
    X = Xee;
L = zeros(size(X,1),1);
for iter = 1:size(X,1) 
    k = zeros(size(Weights,1),1);

    for i = 1:size(Weights,1) 
        
        k(i) = (X(iter,:))*(Weights(i,:))'+ (Bs(i));
    end
    k;
    [~,L(iter)] = max(k);
end
L = L - 1;
end

function feat = extract_feature(image)
%% Description
% This function takes one image as input and returns HOG feature.
%
% Input: image
% Following VLFeat instruction, the input image should be SINGLE precision. 
% If not, the image is automatically converted to SINGLE precision.
%
% Output: feat
% The output is a vectorized HOG descriptor.
% The feature demension depends on the parameter, cellSize.
%
% VLFeat must be added to MATLAB search path. Please check the link below.
% http://www.vlfeat.org/install-matlab.html


%% check input data type
if ~isa(image, 'single'), image = single(image); end;


%% extract HOG 
cellSize = 8;
hog = vl_hog(image, cellSize, 'verbose');
imhog = vl_hog('render', hog, 'verbose');
% clf; imagesc(imhog); colormap gray;


%% feature - vectorized HOG descriptor
feat = hog(:);

end