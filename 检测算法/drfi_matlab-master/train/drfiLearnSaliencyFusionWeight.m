function w = drfiLearnSaliencyFusionWeight( train_dir, gt_dir, num_segmentation, is_resize )
    % Assume that all training images are placed under train_dir.
    % The saliency maps of i-th segmentation are under the folder "i" (e.g., 
    % saliency maps of 3rd segmentation are under the folder "3").
    % Detailed introduction on learning the saliency fusion weight can be
    % found in our supplementary material.
    
    M = num_segmentation;
    
    % Resize all training images to a fixed size 200*200
    sub_dir_list = dir(fullfile(train_dir, '*'));
    
    ind = [];
    for m = 1 : length(sub_dir_list)
        if strcmp(sub_dir_list(m).name, '.') || strcmp(sub_dir_list(m).name, '..')
            ind = [ind, m];
            continue;
        end
    end
    
    % Remove '.' and '..'
    sub_dir_list(ind) = [];
    
    normh = 200;
    normw = 200;
    
    % Resize
    if is_resize
        for m = 1 : length(sub_dir_list)
            image_list = dir(fullfile(train_dir, sub_dir_list(m).name, '*.png'));
            sub_dir_name = sub_dir_list(m).name;

            parfor n = 1 : length(image_list)
                image = imread(fullfile(train_dir, sub_dir_name, image_list(n).name));

                image = imresize(image, [normh, normw]);

                imwrite(image, fullfile(train_dir, sub_dir_name, image_list(n).name));

%                 if mod(jx, 500) == 0
%                     fprintf( 'sub_dir: %s, jx: %d\n', sub_dir_name, jx );
%                 end
            end
            
            fprintf( '%d / %d\n', m, length(sub_dir_list) );
        end
    end
    
    image_list = dir(fullfile(train_dir, sub_dir_list(end).name, '*.png'));
    num_image = length(image_list);
    
    % prepare H and f
    H = zeros(M, M);
    f = zeros(M, 1);
    
    for ii = 1 : M * M
        [m, n] = ind2sub([M, M], ii);
        sub_dir_name_n = sub_dir_list(n).name;
        sub_dir_name_m = sub_dir_list(m).name;
        if m >= n
            temp = zeros(1, num_image);
            parfor k = 1 : num_image
                image_name = image_list(k).name;
                Akm = im2double(imread(fullfile(train_dir, sub_dir_name_m, image_name)));
                Akn = im2double(imread(fullfile(train_dir, sub_dir_name_n, image_name)));
                
                if size(Akm, 3) > 1
                    Akm = rgb2gray( Akm );
                end
                
                if size(Akn, 3) > 1
                    Akn = rgb2gray( Akn );
                end
                
                Nk = 1;%size(Akm, 1) * size(Akm, 2);
                temp(k) = sum(sum(Akm .* Akn)) / Nk;
                % fprintf( 'ix: %d, jx: %d, n: %d\n', ix, jx, n );
            end  
            H(m, n) = 2 * sum( temp );
        else
            H(m, n) = H(n, m);
        end
        
        fprintf( 'Computing H, m: %d, n: %d\n', m, n );
    end
    H = H / num_image;
    save( 'H.mat', 'H' );
%     load( 'H.mat' );

    for m = 1 : M   
        temp = zeros(1, num_image);
        sub_dir_name = sub_dir_list(m).name;
        parfor k = 1 : num_image
            image_name = image_list(k).name;
            Akm = im2double(imread(fullfile(train_dir, sub_dir_name, image_name)));
            if size(Akm, 3) > 1
                Akm = rgb2gray(Akm);
            end
            
            A = imread(fullfile(gt_dir, image_name));
            A = imresize(A, [normh, normw]);
            A = im2double( A );
            if size(A, 3) > 1
                A = rgb2gray(A);
            end
            
            A( A > 0.5 ) = 1.0;
            A( A < 0.5 ) = 0;            
            
            % f(ix) = f(ix) - 2 * sum(sum(A .* Ani));
            % temp = temp - 2 * sum(sum(A .* Ani));
            Nk = 1;%size(A, 1) * size(A, 2);
            temp(k) = - 2 * sum(sum(A .* Akm)) / Nk;
        end     
        f(m) = sum( temp );
        fprintf( 'comupting f, m: %d\n', m );
    end   
    f = f / num_image;
    save( 'f.mat', 'f' );    
    
    % Solve the quadratic programming problem
    w_init = ones(M, 1) / M;
    
    Aeq = ones(1, M);
    beq = 1;
    
    lb = zeros(M, 1);
    ub = ones(M, 1);
    
    opt = optimset( 'Algorithm', 'interior-point-convex' );
    w = quadprog(H, f, [], [], Aeq, beq, lb, ub, w_init, opt );
    
    w( w < 1e-6 ) = 0;
end