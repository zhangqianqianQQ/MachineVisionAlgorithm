function ped_hog = create_data_hog(ped_im_mat, ped_nim_mat, npos, nneg)

% nt = 200;

ped_pos = ped_im_mat(1:npos,:);
ped_pos_hog = [];

ped_neg = ped_nim_mat(1:nneg,:);
ped_neg_hog = [];

for i = 1:npos
    im_p = reshape(ped_pos(i,:),[96 40]);
    im_p = imResample(single(im_p),[96,40])/255;
    hg = hog(im_p,4,9);
    hi = hg(:)';
    ped_pos_hog = vertcat(ped_pos_hog,hi);
end

for i = 1:nneg
    im_n = reshape(ped_neg(i,:),[96 40]);
    im_n = imResample(single(im_n),[96,40])/255;
    hg = hog(im_n,4,9);
    hi = hg(:)';
    ped_neg_hog = vertcat(ped_neg_hog,hi);
end

ped_hog = table([ones(npos,1);zeros(nneg,1)],[ped_pos_hog;ped_neg_hog]);
