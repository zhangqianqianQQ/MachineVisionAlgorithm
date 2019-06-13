name='t1';
image_path=[name '.png'];

i_original=imread(image_path);
im=rgb2gray(i_original);
%im=i_original;

bw=im2bw(im,graythresh(im));
bw=imcomplement(bw); %reverse image;

red1=reduction(bw,1);
red2=reduction(red1,1);

%?? reconstruction of broken drawing lines
% closed=imclose(red2,strel('rectangle',[1 1]));
% thinned=bwmorph(red2,'thin');
% hor = bwhitmiss(thinned,[ 0 0 0
%                           1 1 1
%                           0 0 0]);
% horfilter = fspecial('gaussian',[1 3], 0.5);
% hsmoothed = (imfilter(double(hor), horfilter))*255;
% hsmoothed =im2bw(hsmoothed ,graythresh(hsmoothed));                      

% hole-filling
filled = imfill(red2);

red3=reduction(filled,4);
red4=reduction(red3,3);

opened = imopen(red4,strel('square',5));

exp=expansion(opened);
seed=expansion(exp);

% union of overlapping components
%first match images sizes
[filled, seed]=MatchImageSizes(filled,seed);

h=size(seed,1);
w=size(seed,2);
united=false(h,w);
labeledseed=bwconncomp(seed,4);
labeledred=bwconncomp(filled,4);
for n=1:labeledseed.NumObjects    
    cc=cell2mat(labeledseed.PixelIdxList(n));
    for ii=1:size(cc)
        idx=cc(ii);
        if filled(idx)==1
            %all pixels in this cc =1
            for j=1:size(cc)
                ind=cc(j);
                united(ind)=1;
            end
            %find cc in red2 and =1
            for m=1:labeledred.NumObjects    
                comp=cell2mat(labeledred.PixelIdxList(m));
                if any(comp==idx)
                    for jj=1:size(comp)
                        ind=comp(jj);
                        united(ind)=1;
                    end
                end
            end
            break;
        end
    end
end


% dilation SE=3X3
dilated=gather(imdilate(gpuArray(united),strel('square',3)));

% expantion twice
exp1=expansion(dilated);
exp2=expansion(exp1);

% res=i_original;
% figure, imshow(exp2);
% exp2=cat(3,exp2,exp2,exp2);
% [res, exp2]=MatchImageSizes(res,exp2);
% blobs=bwconncomp(exp2,8);
% parfor n=1:blobs.NumObjects
%     cc=cell2mat(blobs.PixelIdxList(n));
%     top=h; bottom=0; left=w; right=0;
%     for ii=1:size(cc)
%         idx=cc(ii);
%         [i,j]=ind2sub(size(exp2),idx);
%         if i<top
%             top=i;
%         end
%         if i>bottom
%             bottom=i;
%         end
%         if j<left
%             left=j;
%         end
%         if j>right
%             right=j;
%         end
%     end
%     boundaries(n).coords={left,top,(right-left),(bottom-top)};    
% end
% 
% %draw text blobs
% %res = cat(3,i_original,i_original,i_original); % grayscale to rgb!
% shapeInserter = vision.ShapeInserter('Shape','Rectangles','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));
% for n=1:blobs.NumObjects
%     coords =cell2mat(boundaries(n).coords);
%     polygon = int32(coords); 
%     res=step(shapeInserter, res, polygon);
% end


figure, imshow(exp2);
imwrite(exp2,[name '++.jpg'],'jpg');
