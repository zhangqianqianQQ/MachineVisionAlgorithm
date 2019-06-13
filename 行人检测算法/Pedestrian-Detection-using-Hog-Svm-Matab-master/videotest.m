clear all
clc
load 'data.mat';
v=VideoReader('mitsubishi_768x576.avi');

boxwidth=768;
boxheight=576;
hgap=70;
vgap=60;
count=1;
model=model.hog;
 hog_size = 3780;
    scale = 1.2;
    stride = 8;
    show_all = false;
    draw_all = false;
    green = uint8([0,255,0]);
    yellow = uint8([255,255,0]);
    ok_shapeInserter = ...
        vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',green);
    other_shapeInserter = ...
        vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',yellow);

while hasFrame(v)
    readFrame(v);
    count=count+1;
    if count>1000
        break;
    end
end
while hasFrame(v)
    I= readFrame(v);
    %imshow(I);
    [h,w,~] = size(I);
    rscale = min(w/96, h/160);
    I = imresize(I, 1.2/rscale);
    [hogs, windows, wxl, coordinates] = get_pyramid_hogs(I, hog_size, scale, stride);
    [predict_labels, ~, probs] = ...
            svmpredict(zeros(size(hogs,1),1), hogs, model, '-b 1');
         range = 1:max(size(predict_labels));
        pos_indxs = range(predict_labels == 1);
         coordinates = coordinates';
        coordinates = coordinates(pos_indxs,:);
        probs = probs(pos_indxs,:);
        [bb_size, l0_coordinates] = compute_level0_coordinates(wxl, coordinates, pos_indxs, scale);
        if show_all
            windows = windows(:,:,:,pos_indxs);

            for w=1:size(pos_indxs,2)
               figure('name',sprintf('x=%d, y=%d', l0_coordinates(w,1),l0_coordinates(w,2))); 
    %            figure('name',sprintf('x=%d, y=%d', bb_size(w,1),bb_size(w,2))); 
               ii = insertText(windows(:,:,:,w), [1,1], probs(w), 'FontSize',9,'BoxColor', 'green');
               imshow(ii) 
            end
        end
        draw = I;
        shape_inserter = other_shapeInserter;
        if ~draw_all
            
           shape_inserter = ok_shapeInserter;
           max_indxs = non_max_suppression(l0_coordinates, probs, bb_size); 
           pos_indxs = pos_indxs(max_indxs);
           l0_coordinates = l0_coordinates(max_indxs,:);
           bb_size = bb_size(max_indxs, :);
           probs = probs(max_indxs,:);
        end
            
        draw = I;
        for w=1:size(pos_indxs,2)
            x = l0_coordinates(w,1);
            y = l0_coordinates(w,2);
            bb_height = bb_size(w,1);
            bb_width = bb_size(w,2);
            rectangle = int32([x,y,bb_width,bb_height]);
            draw = step(shape_inserter, draw, rectangle);
            draw = insertText(draw, [x,y+bb_height], probs(w), 'FontSize',9,'BoxColor', 'green');
        end
        draw = imresize(draw,2);
        imshow(draw);
        %pause(0.00000001);
end