function [] = MainRealTime( trainDir, videoPath, vidOutputName, s, widthOfBins, thresh )
%  MainRealTime - Takes in a directory path to training images and
% path to video.  First reads in the training images
% (which are one directory below trainDir) and puts
% them in a 256/widthOfBins x 3 x numTrainingImages matrix.  Then
% calls the ProcessVideoRealTimePar function to process the video
% and try to classify objects in the video
%--------------------------------------------------------------------------
%   Author: Stephen Lazzaro
%   CS 766 - Final Project
%   Params: trainDir - directory of training images.  Note there should be
%               a subdirectory in trainDir which contains .jpg images
%           videoPath - the path to the video to be used for testing
%           vidOutputName - the name of video file to output
%           s - the window size that each frame will be split up in to form
%               histograms
%           widthOfBins - the width of the bins for the RGB color
%               histograms
%           thresh - the cutoff distance threshold used to measure whether
%               or not window histograms are close enough to the training
%               histograms.
%
%--------------------------------------------------------------------------
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images...'));
    %First build training histograms
    [trainingHistograms, folderNames] = BuildTrainingHistograms(trainDir, widthOfBins);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading video...'));
    %Now read in video
    video = VideoReader(videoPath);
    
    %TO PROCESS AND SHOW LIVE...HAS INTERFACE FOR TRACKING TO BE ADDED
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing video...'));
    numObjectsToDetect = 1;
    %Call function to process the video and output a video with the objects
    % in training data detected and tracked
    ProcessVideoRealTimePar( video, trainingHistograms, s, widthOfBins, thresh, numObjectsToDetect, vidOutputName, folderNames );

% %code to test speed of video playing without processing
%     tic
%     %vidOutputName = strcat(vidOutputName,'realtime_s',num2str(s),'_binwidth', ...
%     %       num2str(widthOfBins),'_thresh',num2str(abs(thresh)));
%     %vidOut = VideoWriter(vidOutputName);
%     %vidOut.FrameRate = video.FrameRate;
%     
%     hVideoOut = vision.VideoPlayer;
%     hVideoOut.Name  = 'Original Video';
%     hVideoOut.Position = [200 200 1300 800];
%     video = VideoReader(videoPath);
%     %open(vidOut);
%     for i = 1:video.NumberOfFrames
%         frame = read(video, i);
%         step(hVideoOut, frame);
%         %writeVideo(vidOut, frame);
%     end
%     %close(vidOut);
%     toc
    
end