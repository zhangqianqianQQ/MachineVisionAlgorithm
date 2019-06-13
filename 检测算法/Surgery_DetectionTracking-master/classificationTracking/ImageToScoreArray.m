function [ scores] = ImageToScoreArray( image, train, s, w, thresh )
%  ImageToScoreArray - find score for image
%--------------------------------------------------------------------------
%   Params: image - image to be analyzed
%           train - histograms of the training images
%           s - the window size that each frame will be split up in to form
%               histograms
%           w - the width of the bins for the RGB color
%               histograms
%           thresh - the cutoff distance threshold used to measure whether
%               or not window histograms are close enough to the training
%               histograms.
%
%   Returns: scores - matrix of scores for image passed in
%--------------------------------------------------------------------------

 hists = Histograms1D(image,s,w);
 scores = ScoreArray1D(hists,train,thresh);
 scores = Conway(scores);
 scores = Conway(scores);
 
end

