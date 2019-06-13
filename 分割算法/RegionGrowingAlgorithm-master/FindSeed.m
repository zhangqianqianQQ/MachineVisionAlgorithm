function [ seedRow, seedCol ] = FindSeed( imageGray, regionMatrix, peaks )
%GETSEED Find seed point for segmentation
%   Pick seed according to histogram peaks and unlabeled regions

[seedRow, seedCol] = find(regionMatrix == 0, 1);
return;

% % Loop through all peaks of histogram
% for ii = 1 : numel(peaks)
%     
%     % Find rows and cols of the pixels has peak value
%     [seedRows, seedCols] = find(imageGray == peaks(ii));
%     
%     % Loop thourgh all indexes to find seed not in any region
%     for ii = 1 : numel(seedRows)
%         
%         % If ii. th seed is not in any region, pick it as seed
%         if regionMatrix(seedRows(ii), seedCols(ii)) == 0
%             seedRow = seedRows(ii);
%             seedCol= seedCols(ii);
%             return;
%         end
%         
%     end
%     
% end
% 
% seedRow = -1;
% seedCol = -1;
% % 
% [zeroRows, zeroCols] = find(regionMatrix == 0);
% 
% for ii = 1 : numel(zeroRows)
%     
% end
% 
% 
% % If we can't find any peak seeds, we look for remaining zeros
% [seedRow seedCol] = find(regionMatrix == 0, 1);
% 
% if isempty(seedRow) || isempty(seedCol)
%    % If we don't find any seed to start, setting them to -1
%     seedRow = -1;
%     seedCol = -1; 
% end

end

