data_type = 1;  % 1 = gaussian noise, 2 = salt & pepper noise
[clear_img, img] = gen_data(data_type, 0.1);

num_steps = 100;
alpha = 0.1;
showfigs = 0;

%% ROF - alg 1
method = 'ROFalg1';
lambda = 10;
[out_img_rof_alg1, criterion] = TVdenoising(img, method, num_steps, lambda, clear_img, alpha, showfigs);

%% ROF - alg 2
method = 'ROFalg2';
lambda = 10;
[out_img_rof_alg2, criterion] = TVdenoising(img, method, num_steps, lambda, clear_img, alpha, showfigs);

%% TVL1 ROF - alg 1
method = 'TVL1ROFalg1';
lambda = 1;
[out_img_tvL1, criterion] = TVdenoising(img, method, num_steps, lambda, clear_img, alpha, showfigs);

%% Huber ROF - alg 3
method = 'HuberROFalg3';
lambda = 5;
[out_img_huber, criterion] = TVdenoising(img, method, num_steps, lambda, clear_img, alpha, showfigs);

%% Huber-L1 ROF - alg 1
% my own attempt, not in the paper
method = 'HuberL1ROFalg1';
lambda = 0.5;
[out_img_hubertvL1, criterion] = TVdenoising(img, method, num_steps, lambda, clear_img, alpha, showfigs);

%% plots
figure;
subplot(2, 3, 1);
imshow(clear_img);
title('original image');
subplot(2, 3, 2);
imshow(img);
title('salt & pepper noise added');
subplot(2, 3, 3);
imshow(reshape(out_img_rof_alg2, size(img)));
title('ROF (non-robust)');
subplot(2, 3, 4);
imshow(reshape(out_img_tvL1, size(img)));
title({'L1 ROF', '(robust but staircasing)'});
subplot(2, 3, 5);
imshow(reshape(out_img_huber, size(img)));
title({'Huber ROF', '(smooth but non-robust)'});
subplot(2, 3, 6);
imshow(reshape(out_img_hubertvL1, size(img)));
title({'Huber L1 ROF', '(smooth, robust)'});
