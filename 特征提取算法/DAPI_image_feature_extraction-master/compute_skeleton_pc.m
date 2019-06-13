function [level_center]=compute_skeleton_pc(sample,phi,levelnum,overlap)
% this is used to compute the point cloud skeleton
% input sample is the n*3 points
% phi indicates the eigenfunction need to be a colum vector
% levelnum indicates how many levels there are
% overlap is the overlapping between two levels

% output is the level_centers with the last row indicates the levelnumber

level_center=zeros(size(sample,2)+1,1);
levellength=(max(phi)-min(phi))/levelnum;
level=min(phi):levellength:max(phi);
for i=1:levelnum
    if i==1;
        index=find(phi<level(i)+overlap*levellength);
    else
        if i==levelnum
            index=find(phi>level(i+1)-overlap*levellength);
        else
            
            index=find(phi>=level(i)-overlap*levellength&phi<level(i+1)+overlap*levellength);
        end
    end
    slice=sample(index,:);
    size(slice);
    quantile(slice(:,[end]),0.9);
    if size(slice,1)>1
        d=[mean(slice(:,[1:end-1])), quantile(slice(:,[end]),0.9)];
    else
        d=slice;
    end
    %d=mean(slice);
    d=d';
    
    level_center=[level_center,[d;i]];
end

level_center=level_center(:,2:end);


