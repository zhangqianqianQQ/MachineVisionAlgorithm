%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handles index images and grayscale images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function I = imreadRGB(fileName)


[I, cmap] = imread(fileName);
if size(cmap,2) > 0
    Ip = cell(1, size(cmap,2));
    for j=1:size(cmap,2)
        ch = cmap(:,j);
        Ip{j} = ch(I+1);
    end
    I = cat(3, Ip{:});
end
  
if ndims(I) < 3
    I = repmat(I,[1 1 3]);
end