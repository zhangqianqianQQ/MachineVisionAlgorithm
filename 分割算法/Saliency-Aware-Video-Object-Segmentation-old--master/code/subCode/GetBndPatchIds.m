function bdIds = GetBndPatchIds(idxImg, thickness)

if nargin < 2
    thickness = 8;
end
if thickness ==1
    bdIds=[idxImg(1,:)';idxImg(end,:)';idxImg(:,1);idxImg(:,end)];
    bdIds = unique(bdIds);
else
bdIds=unique([
    unique( idxImg(1:thickness,:) );
    unique( idxImg(end-thickness+1:end,:) );
    unique( idxImg(:,1:thickness) );
    unique( idxImg(:,end-thickness+1:end) )
    ]);
end