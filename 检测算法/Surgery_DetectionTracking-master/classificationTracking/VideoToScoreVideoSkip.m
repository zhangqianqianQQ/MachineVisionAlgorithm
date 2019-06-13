function [ out ] = VideoToScoreVideoSkip( video, train, s, w, thresh, skip)
%  VideoToScoreVideoSkip - get component video of video/frame passed in
%--------------------------------------------------------------------------
%   Params: video - should be a height X width X 3 X frames --- array
%           train - histograms of the training images
%           s - the window size that each frame will be split up in to form
%               histograms
%           w - the width of the bins for the RGB color
%               histograms
%           thresh - the cutoff distance threshold used to measure whether
%               or not window histograms are close enough to the training
%               histograms.
%           skip - The frames to skip if vidAllCopy is a video entered
%
%   Returns: out - component video
%--------------------------------------------------------------------------


height = length(video(:,1,1,1));
width = length(video(1,:,1,1));
frames = length(video(1,1,1,:));
H = floor(height/s);
W = floor(width/s);
out = false(H,W,frames);

for i = 1:ceil(frames/skip)
    %display(strcat('frame number: ',num2str((i-1)*skip+1)));
    out(:,:,(i-1)*skip+1) = ImageToScoreArray(video(:,:,:,(i-1)*skip+1), train, s, w, thresh);
    for j = (i-1)*skip+2:min(i*skip, frames)
        out(:,:,j) = out(:,:,(i-1)*skip+1);
    end

end