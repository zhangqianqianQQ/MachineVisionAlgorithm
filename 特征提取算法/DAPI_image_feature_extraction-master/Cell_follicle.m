function [I1]=Cell_follicle(segout, I0, major, u, t3)
%% cut out the inner cells. That may contains partial of the inner cell
addpath InsidePolyFolder
if(~exist('t3','var'))
   t3=10;
end
k_shrink=major./(t3*u);
percent=(3/t3);


[inner(:,2),inner(:,1)]=find(segout==50);
[coeff,score,latent] = princomp(inner);


[boundary(:,2),boundary(:,1)]=find(segout==255);
centerlized=boundary-repmat(mean(inner), size(boundary,1),1);
length=sqrt(sum(centerlized.^2,2));
inner_boundary=(centerlized./repmat(length,1,2)).*repmat(length-min(percent*length, k_shrink),1,2)+repmat(mean(boundary), size(boundary,1),1);
theta=orderpoints(inner_boundary, mean(boundary), coeff);
[trash, index]=sort(theta,'ascend');
xv = [inner_boundary(index,1) ; inner_boundary(index(1),1)]; yv = [inner_boundary(index,2) ; inner_boundary(index(1),2)];
IN = insidepoly(inner(:,1),inner(:,2), xv,yv);

% figure;
% imshow(I0);
% hold on
% scatter(inner_boundary(:,1),inner_boundary(:,2))

I1=I0;

I1(sub2ind(size(I1),inner(IN,2),inner(IN,1)))=0;

%% get rid of the part left
stats = regionprops(I0, 'Area','FilledArea','MajorAxisLength',...
    'MinorAxisLength', 'Orientation', 'Eccentricity','PixelIdxList');
AA=struct2cell(stats);
% area=zeros(1,size(AA,2));
% ratio=zeros(1,size(AA,2));
plist=cell(1,size(AA,2));
for i=1:size(AA,2)
%     area(i)=AA{1,i};
%     ratio(i)=AA{2,i}./AA{3,i};
    plist{i}=AA{7,i};
    if any(I1(plist{i})==0)
        I1(plist{i})=0;
    end
    
end

