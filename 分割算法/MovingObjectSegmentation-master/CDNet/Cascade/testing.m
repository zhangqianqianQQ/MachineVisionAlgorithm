function testing(video)

disp(video);

select_method = 'manual';
frame_num_list = {'50', '100', '150', '200'};


for frame_num_id = 4 : length(frame_num_list)
    frame_num = frame_num_list{frame_num_id};
    tr_m = [select_method, '/' frame_num, '/'];
    load(fullfile('net/', tr_m, video, 'net-epoch-20'));
    net.layers{end} = struct('name', 'data_hat_sigmoid', ...
        'type', 'sigmoid');
    net = vl_simplenn_move(net,'gpu');

    load meanPixel;
    meanPixel(:,:,4) =0;

    half_size = 15;
    
    imgDir = fullfile('../', video, 'Test/input');
    resDir = fullfile('result', select_method, frame_num, video);
    %grayDir = fullfile('..', 'result', select_method, '/', frame_num, video);
    
    %grayDir = fullfile('/media/luoz3301/D010171510170260/Project/Background/GTingTesting/Result/regular_CNN',...
    %        select_method, '/', num2str(frame_num), video);
    %grayDir = fullfile('/home/local/USHERBROOKE/luoz3301/Background/Fuse_SS', video);
    
    grayDir = fullfile('../Result/', select_method, '/', num2str(frame_num), video);


    mkdir(resDir);

    images = dir(fullfile(imgDir, '*.jpg'));
    grayimages = dir(fullfile(grayDir, '*.png'));

    for kk = 1 : numel(images)
        %fprintf('%d\n', kk);
        imagename = images(kk).name;
        grayname = grayimages(kk).name;
        im = single(imread(fullfile(imgDir, imagename)));
        if size(im,1) > 400 || size(im,2) > 400
            im = imresize(im, 0.5, 'nearest');
        end

        im(:,:,4) = single(imread(fullfile(grayDir, grayname)));

        im_large = padarray(im, [half_size, half_size], 'symmetric');
        im_large = bsxfun(@minus, im_large, meanPixel);
        im_large = gpuArray(im_large);

        %     tic;
        A = vl_simplenn(net, im_large);
        B = gather(A(end).x);

        %     toc;

        map_im = uint8(B * 255);
        imwrite(map_im, fullfile(resDir, imagename));
    end
end
