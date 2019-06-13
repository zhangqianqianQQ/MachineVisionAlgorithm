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
