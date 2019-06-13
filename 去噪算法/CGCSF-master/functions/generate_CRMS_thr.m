function CGCSF_CRMS_thr = generate_CRMS_thr( img, block_size, STRFcondition, distortion )
% %------------------------------------------------------------------------
% % function generate_CRMS_thr (Contrast Gain Control with Structural
% % Facilitation). Generates the contrast-detection-thresholds.
% % 
% % Input: img: RGB/Grayscale 8 bit image
% %        block_size: size of the block to divide the image
% %                    recommended to choose such that
% %                    image size is integer multiple of
% %                    the block_size. For example if image
% %                    size is 512x768 block size can be 
% %                    32x32 or 64x64 or 32x64 or 64x32
% %        STRFcondition: Either of the following three
% %                    'AlwaysON': Always use the structural
% %                    facilitation
% %                    'AlwaysOFF': Shuts down the structural
% %                    facilitation. Direct contrast gain
% %                    control model is used
% %                    'ImageDependent': For some images
% %                    it will use structural facilitation,
% %                    some images wont use structural facilitation
% %                    depending on image statistics.
% %        distortion: A distortion image, same size as the input
% %                    image
% %  
% % Output:
% %        CGCSF_CRMS_thr: contrast detection thresholds
% %  
% % Questions?Bugs?
% % Please contact by: Mushfiqul Alam
% %                    mushfiqulalam@gmail.com
% %
% % If you use the codes, cite the following works:
% %     •	Alam, M. M., Vilankar, K.P., Field, D.J., and Chandler, D.M., 
% %     ‘‘Local masking in natural images: A database and analysis,’’ 
% %     Journal of Vision, July 2014, vol. 4, no. 8.
% %     •	Alam, M. M., Nguyen, T., and Chandler, D. M., 
% %     "A perceptual strategy for HEVC based on a convolutional neural 
% %     network trained on natural videos," SPIE Applications of Digital 
% %     Image Processing XXXVIII, August 2015. Doi: 10.1117/12.2188913.    
% %------------------------------------------------------------------------


%---------------------------------------------------
% Declare pixel to luminance conversion parameters
% We found these parameters by measuring the pixel
% to luminance response by measuring luminance
% values of a Dell Trinitron CRT monitor on which
% our psychophysical experiment was performed
%---------------------------------------------------
luminanceConversion.b       = 0.0794;
luminanceConversion.k       = 0.9195*0.03;
luminanceConversion.gamma   = 2.358;

%---------------------------------------------------
% Create the structure map
%---------------------------------------------------
STR = generate_structural_map( img, luminanceConversion, 1 );

%---------------------------------------------------
% Create Contrast Sensitivity Filter
%---------------------------------------------------
csf = make_csf( size(img, 2), size(img, 1), 32);

%---------------------------------------------------
% Declare V1 neuron parameters
%---------------------------------------------------
neural_const_params.g = 0.1;
neural_const_params.q = 2.35;
neural_const_params.p = 2.4;
neural_const_params.b = 0.035;

% Gabor convolution parameters
neural_const_params.nscale            = 6;
neural_const_params.norient           = 6;
neural_const_params.minWaveLength     = 2.35;
neural_const_params.sigmaOnf          = 0.43;
neural_const_params.mult              = 2.45;
neural_const_params.octave            = 2.75;

% Inhibition kernel: Space
temp = fspecial('gaussian', 3, 0.5);
temp(temp<0.0001) = 0;
neural_const_params.spatial_inhibition_kernel = temp;

% Inhibition kernel: Orientation
if rem(neural_const_params.norient, 2) == 0 % checking if norient is even/odd
    shiftStart = neural_const_params.norient/2;
else
    shiftStart = floor(neural_const_params.norient/2);
end

temp1 = zeros(neural_const_params.norient, neural_const_params.norient);

for shiftIdx = 1 : neural_const_params.norient
    
    temp = fspecial('gaussian', [1 neural_const_params.norient], 0.5);
    
    shift = shiftStart-shiftIdx+1;
    
    temp = circshift(temp, [1 -shift]);
    
    temp1(shiftIdx, :) = temp;
    
end

temp1(temp1>=0.0001) = 1;
temp1(temp1<0.0001)  = 0;

temp = zeros(block_size(1)*block_size(2), neural_const_params.norient, neural_const_params.norient);
for i = 1 : neural_const_params.norient
    temp(:, :, i) = repmat(temp1(1, :), [block_size(1)*block_size(2) 1]);
end
neural_const_params.orientation_inhibition_kernel_mat = temp;

% Inhibition kernel: Frequency
if rem(neural_const_params.nscale, 2) == 0 % checking if nscale is even/odd
    shiftStart = neural_const_params.nscale/2;
else
    shiftStart = floor(neural_const_params.nscale/2);
end

temp1 = zeros(neural_const_params.nscale, neural_const_params.nscale);

for shiftIdx = 1 : neural_const_params.nscale
    
    temp = fspecial('gaussian', [1 neural_const_params.nscale], 0.5);
    
    shift = shiftStart-shiftIdx+1;
    
    if shift >= 0
        temp(1:shift)=0;
    else if shift < 0
            temp(end+shift+1:end)=0;
        end
    end
    
    temp = circshift(temp, [1 -shift]);
    
    temp1(shiftIdx, :) = temp;
    
end

temp1(temp1>=0.0001) = 1;
temp1(temp1<0.0001)  = 0;


temp = zeros(block_size(1)*block_size(2), neural_const_params.nscale, neural_const_params.nscale);
for i = 1 : neural_const_params.nscale
    temp(:, :, i) = repmat(temp1(1, :), [block_size(1)*block_size(2) 1]);
end
neural_const_params.freq_inhibition_kernel_mat = temp;

% pooling parameters
neural_const_params.beta_theta  = 1.5;      % Minkowski exponent
neural_const_params.beta_u      = 2;        % Minkowski exponent
neural_const_params.beta_f      = 1.5;      % Minkowski exponent
neural_const_params.d_lim = 1;

%---------------------------------------------------
% Pixel to luminance conversion
%---------------------------------------------------
luminance_img = ( luminanceConversion.b + luminanceConversion.k * img ).^( luminanceConversion.gamma );

%---------------------------------------------------
% Apply CSF
%---------------------------------------------------
% size(csf)
% size(luminance_img)
csfd_img      = real( ifft2( ifftshift( fftshift( fft2( luminance_img ) ).* csf ) ) );
csfd_img(csfd_img<0) = 0;

%---------------------------------------------------
% Gabor decomposition of reference image
%---------------------------------------------------
reference_Gabor = gaborconvolve_BW( csfd_img, neural_const_params.nscale,...
    neural_const_params.norient, neural_const_params.minWaveLength,...
    neural_const_params.sigmaOnf, neural_const_params.mult );

%---------------------------------------------------
% Blocking the reference image
%---------------------------------------------------
luminance_img_block = ( blocking_function(luminance_img, block_size, 0) )';
luminance_img_block = luminance_img_block(:);

%---------------------------------------------------
% Blocking the distortion image
%---------------------------------------------------
distortion_block = ( blocking_function(distortion, block_size, 0) )';
distortion_block = distortion_block(:);

%---------------------------------------------------
% Blocking the Gabor decomposition of reference image
%---------------------------------------------------
total_no_of_blocks = (size(img, 1)/block_size(1)) * (size(img, 2)/block_size(2));

reference_Gabor_block = cell( neural_const_params.nscale, neural_const_params.norient, total_no_of_blocks );
for scale_idx = 1 : neural_const_params.nscale
    for orient_idx = 1 : neural_const_params.norient
        temp = reference_Gabor{ scale_idx, orient_idx };
        temp = ( blocking_function(temp, block_size, 0) )';
        temp = temp(:);
        for block_idx = 1 : total_no_of_blocks
            reference_Gabor_block{scale_idx, orient_idx, block_idx} = temp{block_idx};
        end
    end
end

%---------------------------------------------------
% Gabor decomposition of distortion image
%---------------------------------------------------
distortion_Gabor = gaborconvolve_BW( distortion, neural_const_params.nscale,...
    neural_const_params.norient, neural_const_params.minWaveLength,...
    neural_const_params.sigmaOnf, neural_const_params.mult);

%---------------------------------------------------
% Blocking the Gabor decomposition of distortion image
%---------------------------------------------------
distortion_Gabor_block = cell(neural_const_params.nscale, neural_const_params.norient, total_no_of_blocks);
for scale_idx = 1 : neural_const_params.nscale
    for orient_idx = 1 : neural_const_params.norient
        temp = distortion_Gabor{scale_idx, orient_idx};
        temp = ( blocking_function(temp, block_size, 0) )';
        temp = temp(:);
        for block_idx = 1 : total_no_of_blocks
            distortion_Gabor_block{scale_idx, orient_idx, block_idx} = temp{block_idx};
        end
    end
end


%---------------------------------------------------
% Checking if structural facilitation would be performed or not
%---------------------------------------------------
thr1 = 0.04;
thr2 = 3.5;
slp_param  = 0.005;
prc_param  = 80;
peak_param = 8/10;

C_on  = 1 - (peak_param./(1+exp(-(STR-prctile(STR(:), prc_param))/slp_param)));
C_off = ones(size(img));

if strcmp(STRFcondition, 'ImageDependent')
    if (max(STR(:))) > thr1 && (kurtosis_function(STR(:)) > thr2) % Apply structural masking
        disp('Structure Making ON.');
        C = C_on;
    else % do NOT apply structural masking
        disp('Structure Making OFF.');
        C = C_off;
    end
elseif strcmp(STRFcondition, 'AlwaysON')
    C = C_on;
elseif strcmp(STRFcondition, 'AlwaysOFF')
    C = C_off;
else
    disp('"STRFcondition" must be either of the three: ImageDependent, AlwaysON, or AlwaysOFF');
    disp('Moving forward with AlwaysON parameter');
    C = C_on;
end

C_blk = blocking_function(C, block_size, 0)';
C_blk = C_blk(:);


bisection_iteration_limit = 75;
CGCSF_CRMS_thr = zeros(total_no_of_blocks, 1);

%---------------------------------------------------
% Block-by-block contrast-detection-threshold
% calculation
%---------------------------------------------------
for block_index = 1 : total_no_of_blocks

    disp('---------------------------------------------');
    disp([num2str(100*(block_index/total_no_of_blocks), '%1.1f') ' percent done.']);
    
    
    % Calculating the response for Original Mask Patches
    r_ref_block = contrast_gain_control_model( reference_Gabor_block(:, :, block_index),...
        neural_const_params.nscale, neural_const_params.norient,...
        neural_const_params.p, neural_const_params.q,...
        neural_const_params.b, neural_const_params.g,...
        neural_const_params.spatial_inhibition_kernel,...
        neural_const_params.orientation_inhibition_kernel_mat,...
        neural_const_params.freq_inhibition_kernel_mat,...
        C_blk{block_index} );
    
    % Calculating the divisive gain-controlled output for mask alone
    % creating the patch for first iteration
    alpha_lo = 0;
    alpha_hi = 100;
    alpha    = ( alpha_lo + alpha_hi ) / 2;
    
    % log-Gabor of distorted image block = log-Gabor of distortet
    % image block + alpha*log-Gabor of errog image block
    distorted_img_Gabor_block = cell(neural_const_params.nscale, neural_const_params.norient);
    
    for scale_idx = 1 : neural_const_params.nscale
        for orient_idx = 1 : neural_const_params.norient
            distorted_img_Gabor_block{scale_idx, orient_idx} =...
                reference_Gabor_block{scale_idx, orient_idx, block_index} +...
                alpha.*distortion_Gabor_block{scale_idx, orient_idx, block_index};
        end
    end
    
    % Calculating the RMS contrast
    tAct = log10( std2(alpha*distortion_block{block_index}) / mean2(luminance_img_block{block_index}) );
    
    % Calculating the response for distorted image
    r_dst_block = contrast_gain_control_model( distorted_img_Gabor_block,...
        neural_const_params.nscale, neural_const_params.norient,...
        neural_const_params.p, neural_const_params.q,...
        neural_const_params.b, neural_const_params.g,...
        neural_const_params.spatial_inhibition_kernel,...
        neural_const_params.orientation_inhibition_kernel_mat,...
        neural_const_params.freq_inhibition_kernel_mat,...
        C_blk{block_index} );
    
    % Starting the Bisection iterations to find the thresholds
    iter = 0;
    
    while(1)
        
        % iteration number
        iter = iter + 1;
        
        if ( iter > bisection_iteration_limit )
            disp(['Bisection search did NOT converge for block no ' num2str(block_index)]);
            break;
        end
        
        if iter > 1
            
            % Creating distorted patch depending on updated alpha
            distorted_img_Gabor_block = cell(neural_const_params.nscale, neural_const_params.norient);
            for scale_idx = 1 : neural_const_params.nscale
                for orient_idx = 1 : neural_const_params.norient
                    distorted_img_Gabor_block{scale_idx, orient_idx} =...
                        reference_Gabor_block{scale_idx, orient_idx, block_index} +...
                        alpha.*distortion_Gabor_block{scale_idx, orient_idx, block_index};
                end
            end
            
            % Calculating the RMS contrast for updated alpha
            tAct = log10( std2(alpha*distortion_block{block_index}) / mean2(luminance_img_block{block_index}) );
            
            % Calculating the neural response of the updated distorted image
            r_dst_block = contrast_gain_control_model( distorted_img_Gabor_block,...
                neural_const_params.nscale, neural_const_params.norient,...
                neural_const_params.p, neural_const_params.q,...
                neural_const_params.b, neural_const_params.g,...
                neural_const_params.spatial_inhibition_kernel,...
                neural_const_params.orientation_inhibition_kernel_mat,...
                neural_const_params.freq_inhibition_kernel_mat,...
                C_blk{block_index} );
            
        end
        
        % Calculating d
        orient_cell = cell(1, neural_const_params.norient);
        for orient_idx = 1 : neural_const_params.norient
            temp = zeros(block_size(1), block_size(2));
            for scale_idx = 1 : neural_const_params.nscale
                temp = temp + ( abs( r_ref_block{scale_idx, orient_idx} -...
                    r_dst_block{scale_idx, orient_idx} ) ).^(neural_const_params.beta_f);
            end
            orient_cell{orient_idx} = temp;
        end
        
        temp = zeros(block_size(1), block_size(2));
        for orient_idx = 1 : neural_const_params.norient
            temp = temp + (orient_cell{orient_idx}).^(neural_const_params.beta_theta/neural_const_params.beta_f);
        end
        
        d = ( sum(sum(temp.^(neural_const_params.beta_u/neural_const_params.beta_theta))) ).^(1/neural_const_params.beta_u);
        
        disp(['|d-d_thr|: ' num2str(abs(d-neural_const_params.d_lim))]);
        
        % stopping condition
        if abs(d-neural_const_params.d_lim) < 0.05
            break;
        end
        
        % Updating the left and right alpha
        if d >= neural_const_params.d_lim% && d(iter)< 30
            alpha_hi = alpha;
            alpha = ( alpha_lo + alpha_hi ) / 2;
        elseif d < neural_const_params.d_lim % && iter>=2
            alpha_lo = alpha;
            alpha = ( alpha_lo + alpha_hi ) / 2;
        end
        
    end
    
    CGCSF_CRMS_thr(block_index) = 20*tAct;
    
end

CGCSF_CRMS_thr = reshape(CGCSF_CRMS_thr, [(size(img, 2)/block_size(2)) (size(img, 1)/block_size(1))])';