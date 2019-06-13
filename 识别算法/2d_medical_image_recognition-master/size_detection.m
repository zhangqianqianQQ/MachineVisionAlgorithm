global_fp = 0;
global_fn = 0;
global_tn = 0;
global_tp = 0;
sample = 90;

for i = 1:sample 
    close all;
    load(['Detection/img' num2str(i) '/img' num2str(i) '_detection.mat']);
    img = rgb2gray(im2single(imread(['Detection/img' num2str(i) '/img' num2str(i) '.bmp'])));
    
    % -------------------------------------------------------------------------
    % Process the ground true data
    % -------------------------------------------------------------------------
    temp = zeros(500);
    for j=1:size(detection, 1)
        temp(max(floor(detection(j, 2)), 1), max(floor(detection(j, 1)), 1)) = 1;
    end
    neg = ~imdilate(temp, strel('disk', 5, 0)) ; % draw a circle around the pixel
    pos = ~neg;

%     Plot the ground true
    figure('Name',['Image: ' num2str(i)]) ; clf ;
    subplot(1,3,1) ; imagesc(img) ; axis equal ; title('image') ;
    hold on;
    plot(detection(:, 1), detection(:, 2), 's', 'MarkerSize',10, 'Color', 'g');
    subplot(1,3,2) ; imagesc(pos) ; axis equal ; title('positive points (blob centres)') ;
    subplot(1,3,3) ; imagesc(neg) ; axis equal ; title('negative points (not a blob)') ;
    colormap gray ;

    % -------------------------------------------------------------------------
    % Detection code
    % -------------------------------------------------------------------------
    min_blob_size = 40; 

    img = vl_imsmooth(img,2); % Blob pixels would melt together
    mask = img < 0.6; % Leave only the darker blob

    % Label blob
    mask=imfill(mask,'holes');
    map=bwlabel(mask);
    labels = setdiff(unique(map),0)';

    result = zeros(size(img,1),size(img,2));

    % Filter blob size
    for j=labels

        blob_pixel = (map==j);
        blob_area = sum(sum(blob_pixel));

        if blob_area > min_blob_size
            result = result | blob_pixel;
        end

    end

    % -------------------------------------------------------------------------
    % Measurement
    % -------------------------------------------------------------------------
    y = zeros(size(pos),'single') ;
    y(pos) = +1 ;
    y(neg) = -1 ;
    
    fp = result > 0 & y < 0 ;
    fn = result < 1 & y > 0 ;
    tn = result <= 0 & y < 0 ;
    tp = result >= 1 & y > 0 ;
    
    global_fp = global_fp + sum(sum(fp>0));
    global_fn = global_fn + sum(sum(fn>0));
    global_tn = global_tn + sum(sum(tn>0));
    global_tp = global_tp + sum(sum(tp>0));
      
end

recall = global_tp/(global_tp+global_fn);
precision = global_tp/(global_tp+global_fp);

f1_score = 2*((precision * recall)/(precision + recall));
