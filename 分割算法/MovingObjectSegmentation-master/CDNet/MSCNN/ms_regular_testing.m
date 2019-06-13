function ms_regular_testing(video, method, frames)

scales = [0.5, 0.75, 1];

load(sprintf('net/%s/%d/%s/net-epoch-20', method, frames, video));

net.layers{end} = struct('name', 'data_hat_sigmoid', ...
    'type', 'sigmoid');
net = vl_simplenn_move(net,'gpu');

load meanPixel;

half_size = 15;

imgDir = fullfile('../Test/', video, '/input');
resDir = fullfile('result/', select_method, num2str(frames), video);

mkdir(resDir);

images = dir(fullfile(imgDir, '*.jpg'));

for kk = 1 : numel(images)
    
    %fprintf('%d\n', kk);
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
        
        B = B + imresize(gather(A(end).x),[m,n]);
        %toc;
    end
    
    B = B / numel(scales);
    
    map_im = uint8(B * 255);
    imagename = strrep(imagename, '.jpg', '.png');
    imwrite(map_im, fullfile(resDir, imagename));
    
end
end
