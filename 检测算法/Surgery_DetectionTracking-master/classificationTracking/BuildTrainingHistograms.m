function [ trainingHistograms, folderNames ] = BuildTrainingHistograms( trainDir, w )
%  BuildTrainingHistograms - Reads in training images from trainDir and 
%  builds RGB histograms for training images in with bin size w.
%--------------------------------------------------------------------------
%   Params: trainDir - directory of training images.  Note there should be
%               a subdirectory in trainDir which contains .jpg images
%           w - the width of the bins for the RGB color
%               histograms
%
%   Returns: trainingHistograms - the histograms for the training images in
%                         a 256/w x 3 x numTrainingImages matrix
%            folderNames - name of folder holding training images which
%            should be the name of the object of interest as this will be
%            used in the bounding circle to label the object
%
%--------------------------------------------------------------------------


	widthOfBins = w;
    
    dirContents = dir(trainDir); % all dir contents
    subFolders=[dirContents(:).isdir]; % just subfolder
    folderNames = {dirContents(subFolders).name};    %subfolder names
    folderNames(ismember(folderNames,{'.','..'})) = []; %remove
    imgFiles = dir(strcat(trainDir, '/', folderNames{1}, '/', '*.jpg')); 
    
    trainingHistograms = zeros( 256/widthOfBins, 3, length(imgFiles) );
    
    for i = 1:length(imgFiles);
        currImage = imread(strcat(trainDir, '/',folderNames{1}, '/', imgFiles(i).name));
    	currHist = SimpleHist1D(double(currImage), widthOfBins);
    	trainingHistograms(:,:,i) = currHist(:,:);
    end

end