function [ circles, zerosInARow, realValsInARow, shouldCallDetector ] = DetectObjects( vidAllCopy, trainingHistograms, s, widthOfBins, thresh, skip, circles, zerosInARow, realValsInARow )
%  DetectObjects - Detection method
%--------------------------------------------------------------------------
%   Params: vidAllCopy - should be a video frame
%           trainingHistograms - histograms of the training images
%           s - the window size that each frame will be split up in to form
%               histograms
%           widthOfBins - the width of the bins for the RGB color
%               histograms
%           thresh - the cutoff distance threshold used to measure whether
%               or not window histograms are close enough to the training
%               histograms.
%           skip - The frames to skip if vidAllCopy is a video entered
%           circles - the circles
%           zerosInARow - number of frames straight where zeros
%               detected
%           realValsInARow - The number of detections in a row (in
%               subsequent frames)
%   Returns: circles - position of centroids with first index being row,
%               second one being the column, and third the radius
%            zerosInARow - number of frames straight where zeros
%               detected
%            realValsInARow - The number of detections in a row (in
%               subsequent frames)
%
%--------------------------------------------------------------------------

componentVideo = VideoToScoreVideoSkip( double(vidAllCopy), trainingHistograms, s, widthOfBins, thresh, skip);
[componentVideo, num] = ScoreVideoToComponentVideo( componentVideo );
%display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Timer Will Look For Mean and Radius'));
if (num ~= 0)
    [meanxNew, meanyNew, radiusNew] = GetCircleInfo(componentVideo,s);
    %if object hasn't yet been detected, then set it to new
    %detection as long as been detected twice in a row
    if (meanxNew == 0)
        zerosInARow = zerosInARow + 1;
        realValsInARow = 0;
    else
        realValsInARow = realValsInARow + 1;
        zerosInARow = 0;
        %Good vals is 8
        if (realValsInARow >= 6)
            circles(1,1) = meanxNew;
            circles(1,2) = meanyNew;
            circles(1,3) = radiusNew;
        end
    end
else
    realValsInARow = 0;
end
%display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Detection Finished'));

shouldCallDetector = 1;


end

