function [ maps ] = buildObjectnessMaps( img, NET_params )
%BUILDOBJECTNESSMAP Builds the objectness probability map of an image.
    
    disp('Calculating objectness maps...');

    % Variable for storing an objectness map for each image and patch size
    maps = struct('patch_props', [], 'image_scale', [], 'map', [], 'windows', zeros(1,4), 'confidence', [], 'nWindows', 0);
    input_patch = NET_params.input_patch; % size of the input patch needed for the net
%     patch_props = NET_params.patch_props_sw;
%     img_scales = NET_params.scales;
    sw_scales = NET_params.scales_sw;
    stride_scales = NET_params.scales_stride;
    count_maps = 0;

    %% For each image scale
    nImgScales = length(sw_scales);
    for nIS = 1:nImgScales
        
        % Instead of decreasing the size of the image --> lose of quality
        % we will increase the size of the patch and decrese the size of
        % the stride.
        patch_props = NET_params.patch_props_sw * sw_scales(nIS);
        stride = round(NET_params.stride * stride_scales(nIS));
        size_im = [size(img,1) size(img,2)];
        
%         size_im = size(img_original);
%         size_im = round([size_im(1)*img_scales(nIS) size_im(2)*img_scales(nIS)]);
%         img = imresize(img_original, size_im);
%         stride = round(NET_params.stride * img_scales(nIS));

        %% For each patch_prop
        nPatchProps = size(patch_props,1);
        for nPP = 1:nPatchProps
            count_maps = count_maps+1;
            input_img = NET_params.patch_size;
            input_img = round([input_img(1)*patch_props(nPP,1) input_img(2)*patch_props(nPP, 2)]);

            % Store current map info
            maps(count_maps).patch_props = input_img;
            maps(count_maps).image_scale = size_im;
            maps(count_maps).nWindows = 0;
            
            disp(['  Extracting map with patch_props: [' num2str(input_img) '], image_scale: [' num2str(size_im) '].']);

            % Prepare all the pixels we have to test with patches
            start = 1;
            y_end = size_im(1)-input_img(1)+1;
            x_end = size_im(2)-input_img(2)+1;
            nBatch = 0;

            batch_images = cell(1,NET_params.batch_size);
            [batch_images{:}] = deal(0);
            coord_images = zeros(NET_params.batch_size, 2);

            %% Prepare objectness map
            nComputations = length(start:stride:y_end)*length(start:stride:x_end);
            map = ones(size_im(1), size_im(2), nComputations) * NaN;

            %% Start computation
            count_computations = 1;
            for y = start:stride:y_end
                for x = start:stride:x_end
                    % Get corresponding patch
                    patch = img(y:y+input_img(1)-1, x:x+input_img(2)-1,:);

                    %% Prepare all the images in the current batch
                    nBatch = nBatch+1;
                    coord_images(nBatch,:) = [y x];
                    batch_images{nBatch} = imresize(patch, [input_patch input_patch]);
                    if(nBatch == NET_params.batch_size || count_computations+nBatch-1 == nComputations)
                        %% Apply classifier
                        disp(['    Evaluating ' num2str(count_computations+nBatch-1) '/' num2str(nComputations)]);
                        images = {prepare_batch2(batch_images, true, NET_params.parallel)};
                        scores = caffe('forward', images);
                        scores = squeeze(scores{1});
                        scores = scores(:,1:nBatch)';
                        for nImBatch = 1:nBatch
                            % Store result in objectness map
                            this_score = scores(nImBatch,:);
%                             this_score = this_score(2)-this_score(1);

                            this_y = coord_images(nImBatch,1);
                            this_x = coord_images(nImBatch,2);
                            this_score = this_score(2); % get object probability
                            
                            if(this_score > 0.5)
                                % Object window found, add to the list
                                maps(count_maps).nWindows = maps(count_maps).nWindows+1;
                                maps(count_maps).windows(maps(count_maps).nWindows,:) = [this_x this_y this_x+input_img(2)-1 this_y+input_img(1)-1];
                                maps(count_maps).confidence(maps(count_maps).nWindows) = this_score;
                            end
                            map(this_y:this_y+input_img(1)-1, this_x:this_x+input_img(2)-1, count_computations) = this_score;

                            count_computations = count_computations+1;
                        end
                        nBatch = 0;
                        batch_images = cell(1,NET_params.batch_size);
                        [batch_images{:}] = deal(0);
                    end
                end
            end

            %% Apply mean of the results for obtaining the final objectness map
            %   with values between -1 (No Object) and 1 (Object)
%             map = nanmean(map, 3);
            map = max(map, [], 3);
            map(isnan(map)) = 0;

            % Store current map
            maps(count_maps).map = map;    

        end
    end
end

