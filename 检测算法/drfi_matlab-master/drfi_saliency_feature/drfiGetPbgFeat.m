function pbgdata = drfiGetPbgFeat( imdata )
    % get probable background feature
    % the probable background is estimated as the border near image edge
    % there are 497 features in total ...
    % abs mean R, G, B values       3
    % RGB histogram
    % abs mean L, a, b values       3
    % L*a*b* histogram              8*16*16
    % abs mean H, S, V values
    % HSV histogram
    % abs diff mean texture response 15
    % maximum texture response histogram    15
    % texton histogram
    % location                      8
    
    borderwidth = floor( 15 * max(imdata.imh, imdata.imw) / 400 );
    
    % get pixels in the probable background 
    [h w c] = size( imdata.image_rgb );
    pixels = [1 : h * borderwidth]';
    pixels = [pixels; [h*w : -1 : (h*w - borderwidth*h +1)]'];
    n = 16 : w - 15;
    y1 = 1 : 15;
    y2 = h-14 : h;
    [nn1 yy1] = meshgrid( n, y1 );
    ny1 = (nn1 - 1) * h + yy1;
    pixels = [pixels; ny1(:)];
    [nn2 yy2] = meshgrid( n, y2 );
    ny2 = (nn2 - 1) * h + yy2;
    pixels = [pixels; ny2(:)];    
    
%     segimage = imsegs.segimage;
%     spind = unique(segimage(pixels));
%     
%     pixels = [];
%     for ix = 1 : length(spind)
%         pixels = [pixels; imdata.spstats(spind(ix)).PixelIdxList];
%     end    
    pbgdata.RGBHist = zeros(imdata.nRGBHist, 1);
    
    pbgdata.LabHist = zeros(imdata.nLabHist, 1);
    
    pbgdata.HSVHist = zeros(imdata.nHSVHist, 1);
    
    pbgdata.texture = zeros(imdata.ntext, 1);
    
    pbgdata.textureHist = zeros(imdata.ntext, 1);
    
    pbgdata.lbpHist = zeros(imdata.nlbp, 1);
    
    pbgdata.R = mean( imdata.image_rgb(pixels) );
    pbgdata.G = mean( imdata.image_rgb(pixels + w * h) );
    pbgdata.B = mean( imdata.image_rgb(pixels + w * h * 2) );
    
    pbgdata.RGBHist = hist( imdata.Q_rgb(pixels), 1:imdata.nRGBHist )';
    pbgdata.RGBHist = pbgdata.RGBHist / max( sum(pbgdata.RGBHist), eps );
    
    pbgdata.L = mean( imdata.image_lab(pixels) );
    pbgdata.a = mean( imdata.image_lab(pixels + w * h) );
    pbgdata.b = mean( imdata.image_lab(pixels + w * h * 2) );
    
    pbgdata.LabHist = hist( imdata.Q_lab(pixels), 1:imdata.nLabHist )';
    pbgdata.LabHist = pbgdata.LabHist / max( sum(pbgdata.LabHist), eps );
    
    pbgdata.H = mean( imdata.image_hsv(pixels) );
    pbgdata.S = mean( imdata.image_hsv(pixels + w * h) );
    pbgdata.V = mean( imdata.image_hsv(pixels + w * h * 2) );
    
    pbgdata.HSVHist = hist( imdata.Q_hsv(pixels), 1:imdata.nHSVHist )';
    pbgdata.HSVHist = pbgdata.HSVHist / max( sum(pbgdata.HSVHist), eps );
    
    pbgdata.texture = zeros(imdata.ntext, 1);
    for ix = 1 : imdata.ntext
        pbgdata.texture(ix, 1) = mean( imdata.imtext(pixels + (ix-1) * w * h) );
    end
    
    pbgdata.textureHist = hist( imdata.texthist(pixels), 1:imdata.ntext )';
    pbgdata.textureHist = pbgdata.textureHist / max( sum(pbgdata.textureHist), eps );
    
    pbgdata.lbpHist = hist( imdata.imlbp(pixels), 0:255 )';
    pbgdata.lbpHist = pbgdata.lbpHist / max( sum(pbgdata.lbpHist), eps );
end