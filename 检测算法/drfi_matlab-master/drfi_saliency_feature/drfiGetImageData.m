function imdata = drfiGetImageData( image )    
    g = fspecial('gaussian', 5);
    image = imfilter(image, g, 'same');
    
    image_rgb = im2double( image );
%     image_rgb = rgb2luv( image );
%     image_rgb(:,:,1) = image_rgb(:,:,1) / 100;
%     image_rgb(:,:,2) = (image_rgb(:,:,1) + 100) / 300;
%     image_rgb(:,:,3) = (image_rgb(:,:,1) + 140) / 260;
    
    image_lab = rgb2lab( image_rgb );
    image_lab(:,:,1) = image_lab(:,:,1) / 100;
    image_lab(:,:,2) = image_lab(:,:,2) / 220 + 0.5;
    image_lab(:,:,3) = image_lab(:,:,3) / 220 / 0.5;
    
    image_hsv = rgb2hsv( image_rgb );
    imdata.image_rgb = image_rgb;
    imdata.image_lab = image_lab;
    imdata.image_hsv = image_hsv;
    
    [imh, imw, imc] = size( image_rgb );    
    imdata.imh = imh;
    imdata.imw = imw;
    
    RGB_bins = [8, 8, 8];
    nRGBHist = prod( RGB_bins );
    
    Lab_bins = [8, 8, 8];
    nLabHist = prod(Lab_bins);
    
    HSV_bins = [8, 8, 8];
    nHSVHist = prod( HSV_bins );
    
    ntexthist = 15;
    nloc = 8; % mean x-y, 10th, 90th percentile x-y, w/h, area
    filtext = makeLMfilters;
    ntext = size(filtext, 3);
    
    imdata.nRGBHist = nRGBHist;
    imdata.nLabHist = nLabHist;
    imdata.nHSVHist = nHSVHist;
    
    imdata.nRGB = 3;
    imdata.nLab = 3;
    imdata.nHSV = 3;
    
    imdata.ntexthist = ntexthist;
    imdata.nloc = nloc;
    
    imdata.ntext = ntext;   
    
    imdata.nlbp = 256;      % [0, 255]
    
    % RGB histogram
    R = image_rgb(:,:,1);
    G = image_rgb(:,:,2);
    B = image_rgb(:,:,3);
    
    rr = min( floor(R*RGB_bins(1)) + 1, RGB_bins(1) );
    gg = min( floor(G*RGB_bins(2)) + 1, RGB_bins(2) );
    bb = min( floor(B*RGB_bins(3)) + 1, RGB_bins(3) );
    Q_rgb = (rr-1) * RGB_bins(2) * RGB_bins(3) + ...
            (gg-1) * RGB_bins(3) + ...
            bb + 1;
    
    % Lab histogram
    L = image_lab(:,:,1);
    a = image_lab(:,:,2);
    b = image_lab(:,:,3);
    
    ll = min(floor(L/(1/Lab_bins(1))) + 1, Lab_bins(1));
    aa = min(floor((a)/(1/Lab_bins(2))) + 1, Lab_bins(2));
    bb = min(floor((b)/(1/Lab_bins(3))) + 1, Lab_bins(3));
    Q_lab = (ll-1) * Lab_bins(2) * Lab_bins(3) + ...
        (aa-1) * Lab_bins(3) + ...
        bb + 1;
    
    % HSV histogram
    H = image_hsv(:,:,1);
    % H(H >= 0.5) = 1- H(H >= 0.5);
    S = image_hsv(:,:,2);
    V = image_hsv(:,:,3);
    
    hh = min( floor(H*HSV_bins(1)) + 1, HSV_bins(1) );
    ss = min( floor(S*HSV_bins(2)) + 1, HSV_bins(2) );
    vv = min( floor(V*HSV_bins(3)) + 1, HSV_bins(3) );
    
    Q_hsv = (hh-1) * HSV_bins(2) * HSV_bins(3) + ...
            (ss-1) * HSV_bins(3) + ...
            vv + 1;
    
    imdata.Q_rgb = Q_rgb;
    imdata.Q_lab = Q_lab;
    imdata.Q_hsv = Q_hsv;
    
    % texture - response of filter bank
    grayim = rgb2gray( image );
    imtext = zeros([imh imw ntext]);
    for f = 1:ntext
        response = abs(imfilter(im2single(grayim), filtext(:, :, f), 'same'));    
        response = (response - min(response(:))) / (max(response(:)) - min(response(:)) + eps);
        imtext(:, :, f) = response;
    end
    [dummy, texthist] = max(imtext, [], 3);
    imdata.imtext = imtext;
    imdata.texthist = texthist;
    
    % texture - LBP
    imlbp = mexLBP( grayim );
    imdata.imlbp = double( imlbp );
    
    % location
    yim = 1-repmat(((0:imh-1)/(imh-1))', 1, imw);
    xim = repmat(((0:imw-1)/(imw-1)), imh, 1);
    
    imdata.xim = xim;
    imdata.yim = yim;
    
    imdata.hist_type = 'x2';
