function den = lpa(image)
    
    img = double(image);
    
    [size_z_1,size_z_2]=size(img);    
    sharparam=-1;              % -1 zero order 0 first order (no sharpening) >0 sharpening
    gammaICI=1.05;             % ICI Gamma threshold
    directional_resolution=8;  % number of directions
    fusing=1;                  % fusing type   (1 classical fusing, 2 piecewise regular)
    addnoise=1;                % add noise to observation
    sigma_noise=0.1;           % standard deviation of the noise
    
    h1=[1 2 3 5 7 11];
    h2=max(1,ceil(h1*tan(0.5*pi/directional_resolution)));  % row vectors h1 and h2 need to have the same lenght
    lenh=length(h1);
    
    sig_winds=[ones(size(h1)); ones(size(h2))];    % Gaussian parameter
    beta=1;                     % Parameter of window 6
    window_type=112;  % window=1 for uniform, window=2 for Gaussian
    
    TYPE=10;            % TYPE IS A SYMMETRY OF THE WINDOW
    
    sigma=function_stdEst2D(img);
    
    [kernels, kernels_higher_order]=function_CreateLPAKernels([0 0],h1,h2,TYPE,window_type,directional_resolution,sig_winds,beta);
    [kernelsb, kernels_higher_orderb]=function_CreateLPAKernels([1 0],h1,h2,TYPE,window_type,directional_resolution,sig_winds,beta);
    
    sigmaiter=repmat(sigma,size_z_1,size_z_2);
    stop_condition=0;
    
    clear yh h_opt_Q y_hat_Q var_opt_Q stdh
    YICI_Final1=0; var_inv=0;         YICI_Final2=0;
    CWW=0;
    CWW2=0;
    
    for s1=1:directional_resolution     % directional index
    for s2=1:lenh     % kernel size index
        gha=kernels_higher_order{s1,s2,1}(:,:,1);   %gets single kernel from the cell array
        ghb=kernels_higher_orderb{s1,s2,1}(:,:,1);
        gh=(1+sharparam)*ghb-sharparam*gha;
        ghorigin(s1,s2)=gh((end+1)/2,(end+1)/2);
        bound1=min([(find(sum(gh~=0,2)));abs(find(sum(gh~=0,2))-size(gh,1)-1)]); % removes unnecessary zeroes
        bound2=min([(find(sum(gh~=0,1))),abs(find(sum(gh~=0,1))-size(gh,2)-1)]); % removes unnecessary zeroes
        gh=gh(bound1:size(gh,1)-bound1+1,bound2:size(gh,2)-bound2+1);            % removes unnecessary zeroes
        yh(1:size_z_1,1:size_z_2,s2)= conv2(img+10000,gh,'same')-10000; % Estimation
        stdh(:,:,s2)=repmat(sigma*(sum(gh(:).^2))^0.5,size_z_1,size_z_2);  % Std of the estimate
    end %% for s2, window sizes
    [YICI,h_opt,std_opt]=function_ICI(yh,stdh,gammaICI,2*(s1-1)*pi/directional_resolution);    %%%% ICI %%%%%
    aaa=reshape(ghorigin(s1,h_opt),size(h_opt));  %origin weight for optimal kernels
    y_hat_Q(:,:,s1)=YICI;   h_opt_Q(:,:,s1)=h_opt;   var_opt_Q(:,:,s1)=(std_opt.^2+eps);
    YICI_Final1=YICI_Final1+y_hat_Q(:,:,s1)./var_opt_Q(:,:,s1);            %% FUSING %%%%%
    YICI_Final2=YICI_Final2+y_hat_Q(:,:,s1)./var_opt_Q(:,:,s1)-img.*aaa./var_opt_Q(:,:,s1);            %% FUSING 2 %%%%%
    var_inv=var_inv+1./var_opt_Q(:,:,s1);
    CWW=CWW+aaa./var_opt_Q(:,:,s1);
    CWW2=CWW2+(aaa./var_opt_Q(:,:,s1)).^2;
    
    end
    
    YICI_Final1=YICI_Final1./var_inv;
    YICI_Final2=(YICI_Final2+img.*CWW/directional_resolution)./(var_inv-CWW+CWW./directional_resolution);           %% FUSING 2 %%%%%

    if fusing==1, y_hat=YICI_Final1; end
    if fusing==2, y_hat=YICI_Final2; end
    
    den = y_hat;
    
end
