function [obj_contour_local,i_min,i_max,j_min,j_max] = apply_soacm(img,smap_b,num_epoch)
    % extract local evolving window
    [i_min,i_max,j_min,j_max,lew_rgb] = get_lew(img,smap_b);
    lew_gray = double(rgb2gray(lew_rgb));
    lew_rgb = double(lew_rgb);
    
    % compute the mean color w.r.t all pixels covered by saliency mask
    ort_vec = get_ort_vec(lew_rgb,smap_b(i_min:i_max,j_min:j_max));
    
    % initialize
    [ci,cj] = find(smap_b~=0);
    ci = mean(ci) - i_min;
    cj = mean(cj) - j_min;
    radius = 2;
    [row,col] = size(lew_gray);
    phi_init = sdf2circle(row,col,ci,cj,radius);
    
    % plot initial level set function
%     figure, 
%     imagesc(uint8(lew_gray)),colormap(gray),hold on;
%     plotLevelSet(phi_init,0,'r');
    
    % model parameters
    delta_t = 0.5; 
    lambda_1 = 1;
    lambda_2 = 1;
    nu = 0.5;
    epsilon = 1;
    mu = 0.01 * 255 * 255;
    
    % begin evolving
    phi = phi_init;
    for epc = 1 : num_epoch
        % alternately use gray,r,r,b channel
        delta_t_decay = delta_t * (1-epc/num_epoch);
        window = lew_gray;
        window(:,:,2:4) = lew_rgb;
        choices = [-1,ort_vec];
        ind = 1;
        if epc > fix(num_epoch*0.5)
            ind = mod(epc,4) + 1;
        end
        phi = evol_soacm(choices(ind),window(:,:,ind),phi,mu,nu,lambda_1,lambda_2,delta_t_decay,epsilon);
        
        % plot level set function every 10 iterations
        % if you are evaluating time cost, remember to uncomment this part
%         if mod(epc,10) == 0
%             pause(0.5); % pause 0.5s
%             imagesc(uint8(lew_gray)); colormap(gray)
%             hold on;
%             plotLevelSet(phi,0,'r');
%         end   
    end
    obj_contour_local = ~imbinarize(phi);
end

