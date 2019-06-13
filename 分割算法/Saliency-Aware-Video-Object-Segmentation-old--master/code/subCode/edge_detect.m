function G = edge_detect(im)
% Here we directly use canny

    [BW,~,G]=edge_canny(rgb2gray(im),'canny');
    BW = imdilate(BW,strel('diamond',5));
    BW = single(BW);
    BW(BW==0) = 0.5;
    BW(1:10,:) = 0;
    BW(end-10:end,:) = 0;
    BW(:,1:10) = 0;
    BW(:,end-10:end) = 0;
    G = G.*BW;
end