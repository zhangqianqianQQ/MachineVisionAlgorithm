function [retVoterMask] = generate_voter_mask(voterec,scoresK,scoresK_id,...
        testpos, codebook, valid_vote_idx, imgsz, maskRadius)

if(length(maskRadius)==1)
    maskRadius  = [maskRadius,maskRadius];
end

annolist    = codebook.annolist;
nb_test     = size(testpos, 1);
nhypo       = length(voterec);
retVoterMask= zeros(imgsz(1),imgsz(2),nhypo);

for hyd = 1:nhypo    
    idx_code_curhypo= voterec(hyd).voter_id;
    idx_code_curhypo= valid_vote_idx(idx_code_curhypo);
    idx_fea_curhypo = mod(idx_code_curhypo-1, nb_test) + 1;
    x_pos	= testpos(idx_fea_curhypo, 1);
    y_pos	= testpos(idx_fea_curhypo, 2);
    codeIdx = scoresK_id(idx_code_curhypo);
    
    hypoMask= zeros(imgsz+2*[maskRadius(2),maskRadius(1)]);
    sx  = maskRadius;
    sy  = maskRadius;
    
    for codeEntry = 1:length(codeIdx);
        codeIdxCur=codeIdx(codeEntry);
        c_y = y_pos(codeEntry);
        c_x = x_pos(codeEntry);

        img_id  = codebook.img_id(codeIdxCur);
        obj_id  = codebook.obj_id(codeIdxCur);
        loc     = codebook.location(codeIdxCur,:);
        patch_score = scoresK(idx_code_curhypo(codeEntry));
        objMask = getObjMask(annolist,img_id,obj_id,loc,maskRadius);
        hypoMask= appendDisc(hypoMask,c_x,c_y,sx,sy,maskRadius,patch_score,objMask);

    end
    retVoterMask(:,:,hyd)   = hypoMask(sy+1:sy+imgsz(1),sx+1:sx+imgsz(2));
    winMtx_mask = retVoterMask(:,:,hyd)>eps;
    
    [winMtx_mask2,nb_clr] = bwlabel(winMtx_mask);

    winMtx_mask = dropSmallRegion(winMtx_mask2,nb_clr,300);
    
    retVoterMask(:,:,hyd) = retVoterMask(:,:,hyd).*(winMtx_mask>0);
    
end

function objMask = getObjMask(annolist,img_id,obj_id,loc,maskRadius)

masksz=size(annolist(img_id,obj_id).mask);

mask_tmp = zeros(masksz(1:2) + 2*[maskRadius(2),maskRadius(1)]);

sx = maskRadius(1);
sy = maskRadius(2);

mask_tmp(sy+1:sy+masksz(1),sx+1:sx+masksz(2)) = annolist(img_id,obj_id).mask(:,:,1);

objMask=mask_tmp(sy+loc(2)-maskRadius(2):sy+loc(2)+maskRadius(2),...
    sx+loc(1)-maskRadius(1):sx+loc(1)+maskRadius(1));


function VR = appendDisc(VR,cx,cy,sx,sy,disc_rad,add_value,DISC)
%
rx = round(sx+cx);
ry = round(sy+cy);
if(~exist('DISC','var'))
    [X,Y]=meshgrid(-disc_rad:disc_rad);
    DISC = sqrt(X.^2+Y.^2);
    DISC = (DISC<=disc_rad);
end
DISC = DISC*add_value;

VR((ry-disc_rad):(ry+disc_rad),(rx-disc_rad):(rx+disc_rad))=...
    VR((ry-disc_rad):(ry+disc_rad),(rx-disc_rad):(rx+disc_rad))+DISC;