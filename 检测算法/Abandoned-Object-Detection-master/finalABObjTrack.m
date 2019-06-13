roi = [1 1  480 720];
%Region of interest
maxNumObj = 200; % Maximum number of objects to track
alarmCount = 75; % Max no of frames an object can remain stationary before alarm is raised
maxConsecutiveMiss = 7; %Min frames an object's centroid changes after which it is not tracked

% System object for reading the video with each frame of the type 'Single'
hVideoSrc = vision.VideoFileReader;
hVideoSrc.Filename = input('Enter the video to run:- ','s');
hVideoSrc.VideoOutputDataType = 'single';

% Offsets for drawing bounding boxes in original input video
PtsOffset = int32(repmat([roi(1), roi(2), 0, 0],[maxNumObj 1]));

% Converts RGB image to YCbCr
hColorConv = vision.ColorSpaceConverter('Conversion', 'RGB to YCbCr');

% Does background subtraction on 2 images
hAutothreshold = vision.Autothresholder('ThresholdScaleFactor', 1.0);

% Removes noise and really small blobs
hClosing = vision.MorphologicalClose('Neighborhood', strel('square',10));

% Finds the blobs in the segmented images, properties of blobs also
% specified
hBlob = vision.BlobAnalysis('MaximumCount', maxNumObj, 'ExcludeBorderBlobs', true);
hBlob.MinimumBlobArea = 100;
hBlob.MaximumBlobArea = 5000;

% Creating system objects for players with their locations
pos = [10 300 roi(3)+25 roi(4)+25];
hAbandonedObjects = vision.VideoPlayer('Name', 'Abandoned Objects', 'Position', pos);
pos(1) = 46+roi(3); % move the next viewer to the right
hAllObjects = vision.VideoPlayer('Name', 'All Objects', 'Position', pos);
pos = [80+2*roi(3) 300 roi(3)-roi(1)+25 roi(4)-roi(2)+25];
hThresholdDisplay = vision.VideoPlayer('Name', 'Threshold', 'Position', pos);
mPlayer1=vision.DeployableVideoPlayer('Location',[10,100]);
mPlayer2=vision.DeployableVideoPlayer('Location',[20,110]);
mPlayer3=vision.DeployableVideoPlayer('Location',[20,110]);
mPlayer4=vision.DeployableVideoPlayer('Location',[20,110]);
mPlayer5=vision.DeployableVideoPlayer('Location',[20,110]);

firsttime = true; % Initialisation for storing background
allBlobList=[]; % Used for tracking blobs, stores all information about all blobs
frame_no=0; % Current frame no

% Loop runs till all the video frames are completed
while ~isDone(hVideoSrc)
    frame_no=frame_no+1;
    Im = step(hVideoSrc); % Stores current frame in Im
    OutIm = Im(roi(2):end, roi(1):end, :); % Selects the region of interest from the original video
    YCbCr = step(hColorConv, OutIm); % Gives the YCbCr image of frame
    CbCr = complex(YCbCr(:,:,2), YCbCr(:,:,3)); % CbCr has the color components of YCbCr
    step(mPlayer2,YCbCr); % Dis[plays YCbCr image
    
    % Stores background
    if firsttime
        firsttime = false;
        BkgY = YCbCr(:,:,1);
        BkgCbCr = CbCr;
    end
    
    SegY = step(hAutothreshold, abs(YCbCr(:,:,1)-BkgY)); % Background subtraction on the luminosity part
    SegCbCr = abs(CbCr-BkgCbCr) > 0.05; % Background subtraction on chroma parts
    step(mPlayer3,SegY); % Luminosity subtracted image
    
    % Fill in small gaps in the detected objects and clubs the separated
    % image
    Segmented = step(hClosing, SegY | SegCbCr);
    step(mPlayer1,Segmented); % Foreground
    
    % Perform blob analysis
    [Area, Centroid, BBox] = step(hBlob, Segmented);
    %[x y hitCount latest_detected_frame blob_number starting_frame misscount]
    %[^ ^ ^         ^                      ^           ^              ^]
    for blob=1:size(Centroid,1)%Traverses through the list of Centroids of all the blobs
        %To map x and y to the largest multiple of 5 less than it
        %eg->(103,107)=(100,105)
        roundX=Centroid(blob,1)-mod(Centroid(blob,1),5);
        roundY=Centroid(blob,2)-mod(Centroid(blob,2),5);
        found=false;%to check if the given blob centoid already was there or not 
        for x=1:size(allBlobList,1)
            if(allBlobList(x,1)==roundX && allBlobList(x,2)==roundY)%if the centroid was found
                allBlobList(x,3)=allBlobList(x,3)+1;%increasing the hit count
                found=true;
                allBlobList(x,4)=frame_no;%storing the latest detected frame no.
                allBlobList(x,5)=blob;%storing the blob number of the centroid of that frame
                allBlobList(x,7)=0;%since the blob as detected, miss count will be zero
            end
        end
        if(found==false)%else we need to add the centroid to our list of centroids
            allBlobList=[allBlobList;[roundX roundY 1 frame_no blob frame_no 0 ]];
        end
    end
    BlobCount = size(BBox,1);%to get the total no. o blobs detected in that frame
    
    BBoxOffset = BBox + int32(repmat([roi(1) roi(2) 0 0],[BlobCount 1]));
    Imr = insertShape(Im,'Rectangle',BBoxOffset,'Color','green');%inserting green rectangles for that detected blobs
    myImr=insertMarker(Imr,Centroid);%inserting marker at the centroid of each blob
    rowToRemove=[];%list of all the rows to be  removed since there miss count exceeded the maxMissCount
    for blob=1:size(allBlobList,1)
        %check for the blob to be abandoned
        if(allBlobList(blob,3)>alarmCount && allBlobList(blob,7)<=maxConsecutiveMiss && frame_no==allBlobList(blob,4) )
            %allBlobList(blob,7)=0;
            myImr=insertShape(myImr, 'FilledRectangle', BBox(allBlobList(blob,5), :), 'color','red', 'Opacity', 0.5);
            sound(randn(4096,1),8192);
        %increment the miss count
        else
            allBlobList(blob,7)=allBlobList(blob,7)+1;
            if(allBlobList(blob,7)>maxConsecutiveMiss)%if misscount>maxConsicutiveMiss delete it
                rowToRemove=[rowToRemove;blob];
            end
        end
    end
    %deleting the rows for misscount>maxConsicutiveMiss
    for row=1:size(rowToRemove,1)
        try
        allBlobList(row,:)=[];
        end
    end
    step(hAllObjects, myImr);
    % Display the segmented video
    SegBBox = PtsOffset;
end
release(hVideoSrc);


