function [ out ] = VideoToHistogramList( vidPath, s, w )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

video = VideoReader(vidPath);
NumberOfFramesToRead = ceil(video.NumberOfFrames/10);
HistsPerFrame = video.Height*video.Width/(s^2);
out = zeros(256/w,3,NumberOfFramesToRead*HistsPerFrame);

for i = 1:10:video.NumberOfFrames
   frame = read(video, i);
   out(:,:,(i-1)/10*HistsPerFrame+1:((i-1)/10+1)*HistsPerFrame) = Histograms1D(frame, s, w);
end

end