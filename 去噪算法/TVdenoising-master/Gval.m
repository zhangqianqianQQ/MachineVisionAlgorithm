function dif = Gval(u, gt_img, Lone)
% image similarity part of the criterion

if (Lone)
    dif = sum(abs(u(:) - gt_img(:)));
else
    dif = u(:) - gt_img(:);
    dif = dif' * dif;
end