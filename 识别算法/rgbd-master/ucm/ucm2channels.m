function ucm_o1 = ucm2channels(ucm2,thr,nthr_ori)

ucm = resample_ucm2_orient_new(ucm2,thr,nthr_ori); 
ucm_o1 = quantize_ucm_or(ucm, 8, 1);

%%
function R = quantize_ucm_or(ucm, nori, angSpan)
if nargin<2, nori = 8; end
if nargin<3, angSpan = 1; end % in [1,...,8]. angSpan = 1: no overlap. angSpan = 3: overlap of nori/pi. angSpan = 8: todos los canales tienen full ucm.


strength = ucm.strength(3:2:end,3:2:end);
[tx, ty] = size(strength);
R = zeros(tx, ty, nori);


for o = 0 : nori-1,
    
    angMin = (2*o-angSpan)/nori/2*pi;
    angMax = (2*o+angSpan)/nori/2*pi;
    
    if (angMin >= 0) && (angMax <= pi),
        bw = (ucm.orient > angMin) & (ucm.orient <= angMax);
    elseif (angMin < 0) && (angMax <= pi)
        bw = (ucm.orient > (pi+angMin)) | (ucm.orient <= angMax);
    elseif (angMin >= 0) && (angMax > pi)
        bw = (ucm.orient > angMin) | (ucm.orient <= (angMax-pi) );
    else
        bw = (ucm.orient > (pi+angMin)) | (ucm.orient <= (angMax-pi) );
    end

    R(:, :, o+1) = strength .* ( bw & (ucm.orient~=0));
end 

%%
function ucm = resample_ucm2_orient_new(ucm2, min_thr, nthresh)


thresh = linspace(min_thr, max(ucm2(:)), nthresh)';

[tx2, ty2] = size(ucm2);
img_sz(1) = (tx2-1)/2; img_sz(2) = (ty2-1)/2;

ucm.strength = zeros([tx2, ty2]);
ucm.orient = zeros(img_sz);
old = true([tx2,ty2]);
for t = nthresh:-1:1,
    bw = (ucm2 <= thresh(t));
    if isequal(bw,old), continue; end
    labels2 = bwlabel(bw);
    seg = labels2(2:2:end, 2:2:end);
    bdry = seg2bdry(seg);
    ucm.strength = max(ucm.strength, thresh(t)*bdry);
    
    [seg_ori] = get_segmentation_orientation(bdry(3:2:end,3:2:end));
    ucm.orient = max(ucm.orient,(ucm.orient==0).*seg_ori);
    old = bw;
end

