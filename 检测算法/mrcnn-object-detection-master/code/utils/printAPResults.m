function printAPResults( classes, results )
% 
% This file is part of the code that implements the following ICCV2015 accepted paper:
% title: "Object detection via a multi-region & semantic segmentation-aware CNN model"
% authors: Spyros Gidaris, Nikos Komodakis
% institution: Universite Paris Est, Ecole des Ponts ParisTech
% Technical report: http://arxiv.org/abs/1505.01749
% code: https://github.com/gidariss/mrcnn-object-detection
% 
% AUTORIGHTS
% --------------------------------------------------------
% Copyright (c) 2015 Spyros Gidaris
% 
% "Object detection via a multi-region & semantic segmentation-aware CNN model"
% Technical report: http://arxiv.org/abs/1505.01749
% Licensed under The MIT License [see LICENSE for details]
% ---------------------------------------------------------
if ~isnumeric(results)
    aps = [results(:).ap]';
else
    aps = results;
end

for i = 1:numel(classes)
    class_string = classes{i}(1:min(5,length(classes{i})));
    fprintf('& %5s ', class_string)
end
fprintf('& %5s \\\\ \n', 'mAP')
for i = 1:numel(classes)
    fprintf('& %2.3f ', aps(i))
end
fprintf('& %2.3f \\\\ \n', mean(aps))

end

