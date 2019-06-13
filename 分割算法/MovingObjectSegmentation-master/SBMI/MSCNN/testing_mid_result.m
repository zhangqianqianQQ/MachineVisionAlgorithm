function testing_mid_result(video)

disp(video);

select_method = 'manual';
frame_num_list = {50, 100, 150, 200};

scales = [0.5, 0.75, 1];


for frame_num_id = 4 : 4%length(frame_num_list)
    frame_num = frame_num_list{frame_num_id};
    
    load(sprintf('net/%s%d/%s/net-epoch-20', select_method, frame_num, video));
    
    
    net.layers{end} = struct('name', 'data_hat_sigmoid', ...
        'type', 'sigmoid');
    net = vl_simplenn_move(net,'gpu');
    
    load meanPixel;
    
    half_size = 15;
    
    imgDir = fullfile('..', 'Data', video, 'input');
    resDir = fullfile('result-m', select_method, num2str(frame_num), video);
    
    mkdir(resDir);
    for ii = 1: numel(scales)
        mkdir([resDir '/' num2str(ii)]);
    end
    
    
    images = dir(fullfile(imgDir, '*.jpg'));
    
    for kk = 1 : numel(images)
        
        fprintf('%d\n', kk);
        imagename = images(kk).name;
        im = single(imread(fullfile(imgDir, imagename)));
        if size(im,1) > 400 || size(im,2) > 400
            im = imresize(im, 0.5, 'nearest');
        end
        
        [m,n,~] = size(im);
        B = zeros(size(im,1), size(im,2));
        
        for ss = 1:numel(scales)
            
            im_s = imresize(im, scales(ss), 'nearest');
            
            im_large = padarray(im_s, [half_size, half_size], 'symmetric');
            im_large = bsxfun(@minus, im_large, meanPixel);
            im_large = gpuArray(im_large);
            
            %tic;
            A = vl_simplenn(net, im_large);
             
            imwrite(gather(uint8(A(end).x*255)), fullfile([resDir '/' num2str(ss)], imagename));
            
            B = B + imresize(gather(A(end).x),[m,n]);
            %toc;
        end
        
        B = B / numel(scales);
        
        map_im = uint8(B * 255);
        imagename = strrep(imagename, '.jpg', '.png');
        imwrite(map_im, fullfile(resDir, imagename));
        
    end
end
