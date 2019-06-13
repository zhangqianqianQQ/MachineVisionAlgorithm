function [Width,Height,NumberOfFrames,iscolor,sequence] = ReadInputData(filename)
VidObj = VideoReader(filename);
NumberOfFrames = round(VidObj.FrameRate*VidObj.Duration);
Width = VidObj.Width;
Height = VidObj.Height;
tmpframe = readFrame(VidObj);
if(length(size(tmpframe)) > 2)
    iscolor = 1;
else
    iscolor = 3;
end
sequence = cell(round(NumberOfFrames),1); 
i = 1;
while hasFrame(VidObj)
    tmpframe = readFrame(VidObj);
    sequence{i,1} = tmpframe;
    i = i + 1;
end

end