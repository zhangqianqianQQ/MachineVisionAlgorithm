name='acid1';
image_path=[name '.png'];

mask0=[-1 -1 -1; 2 2 2; -1 -1 -1];
mask45=[-1 -1 2; -1 2 -1; 2 -1 -1];
mask90=[-1 2 -1;-1 2 -1;-1 2 -1];
mask135=[2 -1 -1; -1 2 -1; -1 -1 2];
mask_main=[-1 -1 -1; -1 8 -1; -1 -1 -1];
     
i_original=imread(image_path);
im=rgb2gray(i_original);
%im=i_original;

[h, w]=size(im);

im=gpuArray(im);
i0=gather(imfilter(im,mask0));
i45=gather(imfilter(im,mask45));
i90=gather(imfilter(im,mask90));
i135=gather(imfilter(im,mask135));
arr={i0,i45,i90,i135};

%ie=imfilter(im,mask_main);
ie=i90;

t=120;
%t=graythresh(ie);
strong=Threshold(ie,t);


m=round(w/25);
dilated= bwmorph(strong,'dilate');
closed=gather(imclose(gpuArray(dilated),strel('rectangle',[1 m])));

m=double(ie).*double(closed-dilated);
tw=graythresh(m);
weak=Threshold(m,tw);
bw=strong+weak; %(closed-dilated);


thinned=bwmorph(bw,'thin');
labeled=bwconncomp(thinned,4);


%edge labeling alg
ell=zeros(h,w);
m=0.0;
for n=1:labeled.NumObjects    
    cc=cell2mat(labeled.PixelIdxList(n));
    m=m+size(cc,1);
    for ii=1:size(cc)
        idx=cc(ii);
%         j=rem(idx,w);
%         i=1+fix(idx/w);        
%         if j==0
%             j=w;
%             i=i-1;
%         end
        %[i,j]=ind2sub(size(thinned),idx);
        ell(idx)=size(cc,1);
    end
end
if m~=0
    m=m/labeled.NumObjects;
end
short=InvThreshold(ell,m);
%ell=ell./max(max(ell))*1.0;
%t=NonZeroMean(ell);
%t=graythresh(ell);
%short=InvThreshold(ell,t);


se = strel('square',3);
candidate=short;%imdilate(short,se);

refined=zeros(h,w);
parfor i=1:4
    matr=cell2mat(arr(i));
    refined=refined+double(matr);
end
refined=candidate.*refined;

%fmap calculation with Wt
fmap=zeros(h,w,'int8');
Weight=0;
c=4;
for i=1:h
    for j=1:w
        for k=1:4
            E=cell2mat(arr(k));
            if E(i,j)>t
                Weight=Weight+1;
            end
        end
        
        Nor=zeros(2*c+1,2*c+1);
        for x=-c:1:c
            for y=-c:1:c
                if ((x+i>=1 && x+i<=h) && (y+j>=1 && y+j<=w))
                    idx1=x+i;
                    idx2=y+j;
                    Nor(x+c+1,y+c+1)=refined(idx1,idx2).*Weight;
                end
            end
        end
        denom=norm(norm(Nor));
        if denom>0            
            Nor=Nor./denom;
        end
        fmap(i,j)=sum(sum(Nor));
    end
end

clustered=gather(imdilate(gpuArray(fmap),strel('square',7)));

%H-filtering
blobs=bwconncomp(clustered,8);
%1a calculate area, width, height of each blob
maxarea=0;
areas=zeros(blobs.NumObjects);
widths=zeros(blobs.NumObjects);
heights=zeros(blobs.NumObjects);
parfor n=1:blobs.NumObjects
    cc=cell2mat(blobs.PixelIdxList(n));
    top=h; bottom=0; left=w; right=0;
    for ii=1:size(cc)
        idx=cc(ii);
        [i,j]=ind2sub(size(clustered),idx);
        if i<top
            top=i;
        end
        if i>bottom
            bottom=i;
        end
        if j<left
            left=j;
        end
        if j>right
            right=j;
        end
    end
    boundaries(n).coords={left,top,(right-left),(bottom-top)};
    area=(right-left)*(bottom-top);
    areas(n)=area;
    if area>maxarea
        maxarea=area;
    end
    widths(n)=right-left;
    heights(n)=bottom-top;
end

for n=1:blobs.NumObjects
    cc=cell2mat(blobs.PixelIdxList(n));
    if areas(n)<maxarea/20;
        %delete blob
        for ii=1:size(cc)
            idx=cc(ii);
            clustered(idx)=0;
        end
    end
    ratio=widths(n)/heights(n);
    if ratio<0.2
        %delete blob
        for ii=1:size(cc)
            idx=cc(ii);
            clustered(idx)=0;
        end
    end
end

%draw text blobs
res=i_original;
%res = cat(3,i_original,i_original,i_original); % grayscale to rgb!
shapeInserter = vision.ShapeInserter('Shape','Rectangles','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));
for n=1:blobs.NumObjects
    coords =cell2mat(boundaries(n).coords);
    polygon = int32(coords); 
    res=step(shapeInserter, res, polygon);
end


imshow(res);
%imwrite(res,[name '++.jpg'],'jpg');

