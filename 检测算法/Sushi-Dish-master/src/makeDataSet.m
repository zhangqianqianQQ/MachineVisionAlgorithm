% Dataset Information
% 1 : cyan (1,300 won)
% 2 : purple (1,700 won)
% 3 : green (2,100 won)
% 4 : yellow (2,600 won)
% 5 : brown (3,000 won)
% 6 : red (3,500 won)
% 7 : blue (4,000 won)
% 8 : black (6,000 won)
%
% images.data (101 x 101 x 3 x n) / labels (1xn) / set (1 x n) (n is dataset size)
% 1: train , 2: val , 3: test

function [result, labels, set] = makeDataSet()
    close all;
    figure;
    dirname = 'images/stacked';
    d = dir(dirname);
    result = [];
    labels = [];
    tot_cnt = 0;
    for i = 3:length(d)
        if strcmp(d(i).name,'Thumbs.db') ~= 1
            fname = sprintf('%s\\%s',dirname,d(i).name);
            im = imread(fname);
            display(sprintf('Processing : %s\n',fname));
            % Detects Ellipses from image
            [el, im_re] = detectEllipses(im, false);
            subplot(1, 2, 1);
            imshow(im_re);
            loop_cnt = numel(el);
            for j=1:loop_cnt
               feature = extractFeatureImage(im_re,el,j, false);
               subplot(1, 2, 2);
               imshow(feature);
               lab = input('Label of feature? (input 0 to throw it out) :\n');
               if lab ~= 0
                  % Update result
                  labels = [labels lab];
                  result = cat(4,result,feature);
                  tot_cnt = tot_cnt + 1;
               end
            end
        end
    end
    set = ones(1,tot_cnt);
    % Code to check if dataset is correct 
    % size( data(:,:,:,find(labels==1)) );
    % montage(data(:,:,:,find(labels==1)));
end