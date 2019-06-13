function testing(video)

disp(video);

previousMethod = 'MSCNN'; % BasicCNN or MSCNN

load(fullfile([previousMethod 'net/'], video, 'net-epoch-20'));
net.layers{end} = struct('name', 'data_hat_sigmoid', ...
    'type', 'sigmoid');
net = vl_simplenn_move(net,'gpu');

load meanPixel;
meanPixel(:,:,4) =0;

half_size = 15;

imgDir = ['../SBMIDataset/' video '/input'];
resDir = fullfile([previousMethod '-result'], video);

grayDir = ['../' previousMethod '/result/', video];

mkdir(resDir);
images = [dir([imgDir '/*.jpg']); dir([imgDir '/*.png'])];
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

