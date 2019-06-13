function [ bestThresh ] = ThresholdSelection(  trainDir, image, s, widthOfBins, thresh, p)
% ThresholdSelection - This function is used for selecting the optimal 
% threshold by comparing the
% fraction of the non-thresholded content which lies in the principal
% component.  The variable "p" should represent the fraction of the image
% inputed that contains the desired object... example: p=0.04.
%--------------------------------------------------------------------------
%   Params: trainDir - directory of training images.  Note there should be
%               a subdirectory in trainDir which contains .jpg images
%           s - the window size that each frame will be split up in to form
%               histograms
%           widthOfBins - the width of the bins for the RGB color
%               histograms
%           thresh - the cutoff distance threshold used to measure whether
%               or not window histograms are close enough to the training
%               histograms.
%           p - proportion of pixels containing object of interest
%
%   Returns: bestThresh - a guess for threshold value to choose
%--------------------------------------------------------------------------

    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Processing training images...'));
    trainingHistograms = BuildTrainingHistograms(trainDir, widthOfBins);
    
    display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Reading image...'));
    image = double(image);
    bestThresh = 0;
    bestRatio = 0;
    for t = thresh
        disp('-------------------------------------------------------------');
        disp(strcat('Testing Threshold Value: ',num2str(t)))
        scoreImage = ImageToScoreArray( image, trainingHistograms, s, widthOfBins, t );
        pixels = prod(size(scoreImage)); %#ok<PSIZE>
        [L,num] = bwlabeln(scoreImage);
        max = 0;
        total = 0;
        for i = 1:num
            temp = sum(sum(L==i));
            total = total+temp;
            if (temp>max)
                max = temp;
            end
        end
        display(strcat('Fraction of pixels above threshold:',num2str(total/pixels)));
        display(strcat('Fraction of these pixels in principal component:',num2str(max/total)));
        if (0.9>total/pixels)
            if (total/pixels>p)
                if (max/total>bestRatio)
                    bestRatio = max/total;
                    bestThresh = t;
                end
            end
        end
    end

end

