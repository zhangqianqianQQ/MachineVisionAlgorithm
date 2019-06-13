clear all;
close all;

% This program used to detect moving objects in a video %
% Author: Ravdeep Johar
% Please input any avi file below % 

Video = input('Enter the name of the video file:', 's');
if isempty(Video)
    error('myApp:argChk', 'You did not enter a video file!')
end


inputVideo = aviread(Video);

%  frame size variables 

fr = inputVideo(1).cdata;           % read in 1st frame as background frame
fr_bw = rgb2gray(fr);               % convert background to greyscale
fr_size = size(fr);                 % get the size of the frame
width = fr_size(2);                 % get the width of the frame
height = fr_size(1);                % get the height of the frame
foreground = zeros(height, width);          % initialize variable to store foreground
background = zeros(height, width);       % initialize variable to store background

% 

K = 3;                                           % number of gaussian components (can be upto 3-5)
M = 3;                                           % number of background components
D = 2.5;                                         % positive deviation threshold
alpha = 0.01;                                    % learning rate (between 0 and 1) (from paper 0.01)
foregroundThreshold = 0.25;                      % foreground threshold (0.25 or 0.75 in paper)
sd_initial = 6;                                  % initial standard deviation (for new components) var = 36 in paper
weight = zeros(height,width,K);                  % initialize weights array
mean = zeros(height,width,K);                    % pixel means
standardDeviation = zeros(height,width,K);       % pixel standard deviations
diffFromMean = zeros(height,width,K);            % difference of each pixel from mean
learningRate = alpha/(1/K);                      % initial p variable (used to update mean and sd)
rankComponent = zeros(1,K);                      % rank of components (w/sd)


% initialize components for the  means and weights 

pixel_depth = 8;                        % 8-bit resolution
pixel_range = 2^pixel_depth -1;         % pixel range (# of possible values)

for i=1:height
    for j=1:width
        for k=1:K
            
            mean(i,j,k) = rand*pixel_range;          % means random (0-255), it initialzes the mean to some random value.
            weight(i,j,k) = 1/K;                     % weights uniformly dist
            standardDeviation(i,j,k) = sd_initial;   % initialize to sd_init
            
        end
    end
end

% Applying the proposed algorithm to the video

for n = 1:length(inputVideo)
    % reading the frames.
    fr = inputVideo(n).cdata;  
    % converting the frames to grayscale.
    fr_bw = rgb2gray(fr);       
    
    % calculating the difference of each pixel values from mean.
    for m=1:K
        diffFromMean(:,:,m) = abs(double(fr_bw) - double(mean(:,:,m)));
    end
     
    % update gaussian components for each pixel values.
    for i=1:height
        for j=1:width
            
            match = 0; % its changed to 1 if the component is matched
            for k=1:K  
                % pixel matches component
                if (abs(diffFromMean(i,j,k)) <= D*standardDeviation(i,j,k))       
                    % variable to signal component match
                    match = 1;                          
                    
                    % update weights, mean, standard deviation and
                    % learning factor
                    weight(i,j,k) = (1-alpha)*weight(i,j,k) + alpha;
                    learningRate = alpha/weight(i,j,k);                  
                    mean(i,j,k) = (1-learningRate)*mean(i,j,k) + learningRate*double(fr_bw(i,j));
                    standardDeviation(i,j,k) =   sqrt((1-learningRate)*(standardDeviation(i,j,k)^2) + learningRate*((double(fr_bw(i,j)) - mean(i,j,k)))^2);
                else                                    % if pixel doesn't match component
                    weight(i,j,k) = (1-alpha)*weight(i,j,k);      % weight slighly decreases
                    
                end
            end
            
            weight(i,j,:) = weight(i,j,:)./sum(weight(i,j,:));
            
            %Save the background using all the components of gaussian.            
            background(i,j)=0;
            for k=1:K
                background(i,j) = background(i,j)+ mean(i,j,k)*weight(i,j,k);
            end
            
            % if no components match, create new component and decrease the
            % parameters values
            if (match == 0)
                [min_w, min_w_index] = min(weight(i,j,:));  
                mean(i,j,min_w_index) = double(fr_bw(i,j));
                standardDeviation(i,j,min_w_index) = sd_initial;
            end

            rankComponent = weight(i,j,:)./standardDeviation(i,j,:);             % calculate component's rank
            rankIndex = [1:1:K];
            
            % sort rank values
            for k=2:K               
                for m=1:(k-1)
                    
                    if (rankComponent(:,:,k) > rankComponent(:,:,m))                     
                        % swap max values
                        rank_temp = rankComponent(:,:,m);  
                        rankComponent(:,:,m) = rankComponent(:,:,k);
                        rankComponent(:,:,k) = rank_temp;
                        
                        % swap max index values
                        rank_ind_temp = rankIndex(m);  
                        rankIndex(m) = rankIndex(k);
                        rankIndex(k) = rank_ind_temp;    

                    end
                end
            end
            
            % calculate foreground and save it.
            match = 0;
            k=1;
            
            foreground(i,j) = 0;
            while ((match == 0)&&(k<=M))

                if (weight(i,j,rankIndex(k)) >= foregroundThreshold)
                    if (abs(diffFromMean(i,j,rankIndex(k))) <= D*standardDeviation(i,j,rankIndex(k)))
                        foreground(i,j) = 0;
                        match = 1;
                    else
                        foreground(i,j) = fr_bw(i,j);     
                    end
                end
                k = k+1;
            end
        end
    end
    
    %Structure element for performing morphological operations
     SE=[0 0 0 0 0
        0 1 1 1 0
        0 1 1 1 0
        0 1 1 1 0
        0 0 0 0 0];
    
    %Performing closing on the foreground frames using SE
    closedFrame=imclose(foreground,SE);
    
    % Plotting the foreground , background , original video and the morphed
    % video on the screen.
    figure(1),
    subplot(4,1,1),imshow(fr), title('Original Video');
    subplot(4,1,2),imshow(uint8(background)), title('Background Model');
    subplot(4,1,3),imshow(uint8(foreground)) , title('Foreground( Moving Objects )');
    subplot(4,1,4),imshow(uint8(closedFrame)) , title('After Morphological operation');
    
    % put foreground frames into movie.
    Movie1(n)  = im2frame(uint8(foreground),gray);    
    % put background frames into movie.
    Movie2(n)  = im2frame(uint8(background),gray);
    % put closed frames into movie.
    Movie3(n)  = im2frame(uint8(closedFrame),gray);
    
end
% save foreground movie as avi. 
movie2avi(Movie1,'mixtureOfGaussiansOutput','fps',30);  
% save background movie as avi.
movie2avi(Movie2,'mixtureOfGaussiansBackground','fps',30); 
% save closed movie as avi.
movie2avi(Movie3,'mixtureOfGaussiansMorphologicalOperation','fps',30); 