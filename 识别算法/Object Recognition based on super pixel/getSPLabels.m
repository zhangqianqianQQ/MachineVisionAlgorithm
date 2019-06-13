
% Selams, getSPLabels returns labels of Superpixels as well as number of
% total pixels in the image. It takes four parameters. One is image_input
% second one is Superpixel count limit. Third one is type. Use 1 for SLIC
% algorithm and other numbers for SLICO algorithm. BEWARE, if you are using
% type 1, which is SLIC, you have to set fourth parameter, compactness too.
% For more information, check SLIC and SLICO algorithms. If you are using
% type 2 or something else, just put random value to compactness, preferably
% ~ symbol for ignoring.
function [labels,numLabels] = getSPLabels(image_input,SPLimit,type,compactness)
% First, lets see if we have that files
conf;

% If 1 == SLIC, if 2 == SLICO
if type == 1
    [labels, numLabels] = slicmex(image_input,SPLimit,compactness);
else 
    [labels, numLabels] = slicomex(image_input,SPLimit);
end

end

