function  [ConSPix ConEdge]= find_connect_superpixel(labels, K, height ,width )
%%
% obtain the neighbour relationship of the super-pixels
% Input: 
%         labels:    the super-pixel label obtained from SLIC
%         K:         the number of super-pixels
%         height:    the height of the image
%         width:     the width of the image
% Output:
%         ConPix:   the one layer neighbour relationship
%%%%=====================================================
ConSPix=zeros(K,K);
%the one outerboundary super
for i=1:height-1
    for j=1:width-1
        if labels(i,j)~=labels(i,j+1)
            ConSPix(labels(i,j) ,labels(i,j+1) )=1;
        end
        if labels(i,j)~=labels(i+1,j)
            ConSPix(labels(i,j) ,labels(i+1,j) )=1;
        end
    end
    if labels(i,j+1)~=labels(i+1,j+1)
        ConSPix(labels(i,j+1) ,labels(i+1,j+1 ) )=1;
    end
end
for j=1:width-1
    if labels(height,j)~=labels(height,j+1)
        ConSPix( labels(height,j),labels(height,j+1) )=1;
    end
end
for i=1:height-1
    for j=1:width-1
        if labels(i,j)~=labels(i+1,j+1)
            ConSPix( labels(i,j),labels(i+1,j+1) )=1;
        end
    end
end
for i=1:height-1
    for j=2:width
        if labels(i,j)~=labels(i+1,j-1)
            ConSPix( labels(i,j),labels(i+1,j-1) )=1; 
        end
    end
end
 ConSPix = ConSPix + ConSPix';
 ConSPix(ConSPix>0)=1;
 [edges_x edges_y] = find(triu(ConSPix)==1);
 ConEdge = [edges_x edges_y];
 %[x y] = meshgrid(1:K,1:K);
 %ConEdge = [x(:) y(:)];


     


