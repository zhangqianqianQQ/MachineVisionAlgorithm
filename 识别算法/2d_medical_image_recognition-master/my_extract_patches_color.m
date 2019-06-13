function imdb = my_extract_patches_color(sample, ratio_trainning)

    trainning_size = 0;
    curr_size = 0;
    total_size = 0;

    % Find amount of patches
    for i = 1:sample 
        location_epi = load(['Classification/img' num2str(i) '/img' num2str(i) '_epithelial.mat']);
        location_fib = load(['Classification/img' num2str(i) '/img' num2str(i) '_fibroblast.mat']);
        location_inf = load(['Classification/img' num2str(i) '/img' num2str(i) '_inflammatory.mat']);
        location_oth = load(['Classification/img' num2str(i) '/img' num2str(i) '_others.mat']);
        total_size = total_size + size(location_epi.detection, 1)+size(location_fib.detection, 1)+size(location_fib.detection, 1)+size(location_oth.detection, 1);
    end

    trainning_size = floor(total_size * ratio_trainning);

    % Init 
    imdb.images.data = im2single(zeros(27, 27, 3, total_size));
    imdb.images.label = zeros(1, total_size);
    imdb.images.id = zeros(1, total_size);
    imdb.images.set = zeros(1, total_size);

    for i = 1:sample 
        % Load ground true 
        location_epi = load(['Classification/img' num2str(i) '/img' num2str(i) '_epithelial.mat']);
        location_fib = load(['Classification/img' num2str(i) '/img' num2str(i) '_fibroblast.mat']);
        location_inf = load(['Classification/img' num2str(i) '/img' num2str(i) '_inflammatory.mat']);
        location_oth = load(['Classification/img' num2str(i) '/img' num2str(i) '_others.mat']);
        im = im2single(imread(['Classification/img' num2str(i) '/img' num2str(i) '.bmp']));
        
%         close all;
%         figure('Name',['Classification Image: ' num2str(i)]) ; clf ;
%         subplot(1,4,1) ; imagesc(im) ; axis equal ; title('Epithelial') ; hold on;
%         plot(location_epi.detection(:, 1), location_epi.detection(:, 2), 's', 'MarkerSize',10, 'Color', 'g');
%         subplot(1,4,2) ; imagesc(im) ; axis equal ; title('Fibroblast') ; hold on;
%         plot(location_fib.detection(:, 1), location_fib.detection(1, 2), '*', 'MarkerSize',10, 'Color', 'g');
%         subplot(1,4,3) ; imagesc(im) ; axis equal ; title('Inflammatory') ; hold on;
%         plot(location_inf.detection(:, 1), location_inf.detection(:, 2), 's', 'MarkerSize',10, 'Color', 'g');
%         subplot(1,4,4) ; imagesc(im) ; axis equal ; title('Others') ; hold on;
%         plot(location_oth.detection(:, 1), location_oth.detection(:, 2), 's', 'MarkerSize',10, 'Color', 'g');
        
        % Epithelial
        set_size =  0;
        for j=1:size(location_epi.detection, 1)
            row1 = floor(location_epi.detection(j, 1) - 13);
            col1 = floor(location_epi.detection(j, 2) - 13);
            subImage = imcrop(im, [row1, col1, 26, 26]); 

            set_size = set_size + 1;
            if size(subImage, 1) == 27 && size(subImage, 2) == 27
                imdb.images.id(1, curr_size + set_size) = curr_size + set_size;
                imdb.images.data(:, :, :, curr_size + set_size) = im2single(subImage);
                imdb.images.label(1, curr_size + set_size) = 1;
                if(curr_size + set_size <= trainning_size)
                    imdb.images.set(1, curr_size + set_size) = 1; % train
                else
                    imdb.images.set(1, curr_size + set_size) = 2; % validation
                end
            else
                set_size = set_size - 1;
            end

        end
        curr_size = curr_size + set_size;

        % Fibroblast
        set_size =  0;
        for j=1:size(location_fib.detection, 1)
            row1 = floor(location_fib.detection(j, 1) - 13);
            col1 = floor(location_fib.detection(j, 2) - 13);
            subImage = imcrop(im, [row1, col1, 26, 26]);

            set_size = set_size + 1;
            if size(subImage, 1) == 27 && size(subImage, 2) == 27
                imdb.images.id(1, curr_size + set_size) = curr_size + set_size;
                imdb.images.data(:, :, :, curr_size + set_size) = im2single(subImage);
                imdb.images.label(1, curr_size + set_size) = 2;
                if(curr_size + set_size <= trainning_size)
                    imdb.images.set(1, curr_size + set_size) = 1;
                else
                    imdb.images.set(1, curr_size + set_size) = 2;
                end
            else
                set_size = set_size - 1;
            end

        end
        curr_size = curr_size + set_size;

        % Inflammatory
        set_size =  0;
        for j=1:size(location_inf.detection, 1)
            row1 = floor(location_inf.detection(j, 1) - 13);
            col1 = floor(location_inf.detection(j, 2) - 13);
            subImage = imcrop(im, [row1, col1, 26, 26]);

            set_size = set_size + 1;
            if size(subImage, 1) == 27 && size(subImage, 2) == 27
                imdb.images.id(1, curr_size + set_size) = curr_size + set_size;
                imdb.images.data(:, :,  :, curr_size + set_size) = im2single(subImage);
                imdb.images.label(1, curr_size + set_size) = 3;
                if(curr_size + set_size <= trainning_size)
                    imdb.images.set(1, curr_size + set_size) = 1;
                else
                    imdb.images.set(1, curr_size + set_size) = 2;
                end
            else
                set_size = set_size - 1;
            end

        end
        curr_size = curr_size + set_size;

        % Others
        set_size =  0;
        for j=1:size(location_oth.detection, 1)
            row1 = floor(location_oth.detection(j, 1) - 13);
            col1 = floor(location_oth.detection(j, 2) - 13);
            subImage = imcrop(im, [row1, col1, 26, 26]);

            set_size = set_size + 1;
            if size(subImage, 1) == 27 && size(subImage, 2) == 27
                imdb.images.id(1, curr_size + set_size) = curr_size + set_size;
                imdb.images.data(:, :, :, curr_size + set_size) = im2single(subImage);
                imdb.images.label(1, curr_size + set_size) = 4;
                if(curr_size + set_size <= trainning_size)
                    imdb.images.set(1, curr_size + set_size) = 1;
                else
                    imdb.images.set(1, curr_size + set_size) = 2;
                end
            else
                set_size = set_size - 1;
            end

        end
        curr_size = curr_size + set_size;
    end

    % Ignore corrupted patches
    imdb.images.data = imdb.images.data(:, :, :, 1:curr_size);
    imdb.images.label = imdb.images.label(1, 1:curr_size);
    imdb.images.id = imdb.images.id(1, 1:curr_size);
    imdb.images.set = imdb.images.set(1, 1:curr_size);

end