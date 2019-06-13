function [ objectsCV, files ] = loadCV( file )

    %% Load files
    files = dir([file '/Cross*.mat' ]);

%     nFiles = length(files);
%     count_imgs = 0;
%     for i = 1:nFiles
%         disp(['Reading file ' files(i).name]);
%         load([file '/' files(i).name]); % objectsCV
%         nImgs = length(objectsCV);
%         for j = 1:nImgs
%             objectsCV_aux(count_imgs+1) = objectsCV(j);
%             count_imgs = count_imgs+1;
%         end
%     end
% 
%     objectsCV = objectsCV_aux;

    if(length(files) > 1)
        load([file '/' files(1).name]); % objectsCV
    else
        error('No CV files found.');
    end

end

