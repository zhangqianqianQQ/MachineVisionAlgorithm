function r_p  = contrast_gain_control_model( Gbr, nscale, norient, p, q, b, g,...
                    SpatialInhibitoryKernel, OrInhibitKernelMat,...
                    FreqInhibitKernelMat,...
                    test_param )
% %------------------------------------------------------------------------
% % function contrast_gain_control_model. 
% % calculates the V1 simple cell neuron response
% % Similar operations as Watson & Solomon contrast-gain-control model
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

%% Excitatory/Inhibitory nonlinearity
% Excitory
[ Gbr_p_even  , Gbr_p_odd ] = excitory_nonlinearity( Gbr, p );
% Inhibitory
[ Gbr_q_even  , Gbr_q_odd ] = excitory_nonlinearity( Gbr, q );

%% Pooling in inhibitory response
Gbr_p = cell(nscale, norient); Gbr_q = cell(nscale, norient);
SpaceInhibit = cell(nscale, norient);


for orient_idx = 1 : norient
    for scale_idx = 1 : nscale

        % Complete Summation over phase
        Gbr_p{scale_idx, orient_idx} = ( Gbr_p_even{scale_idx, orient_idx} + Gbr_p_odd{scale_idx, orient_idx} );
        Gbr_q{scale_idx, orient_idx} = ( Gbr_q_even{scale_idx, orient_idx} + Gbr_q_odd{scale_idx, orient_idx} );

        % Spatial pooling
        SpaceInhibit{scale_idx, orient_idx} = conv2( Gbr_q{scale_idx, orient_idx}, SpatialInhibitoryKernel, 'same' );

    end
end

sz1 = size(Gbr_q{1, 1}, 1);
sz2 = size(Gbr_q{1, 1}, 2);
% Orientational pooling
OrientInhibit = OrientInhibitFunc( Gbr_q, OrInhibitKernelMat, sz1, sz2, nscale, norient  );
% Spatial Frequency pooling
FreqInhibit = FreqInhibitFunc( Gbr_q, FreqInhibitKernelMat, sz1, sz2, nscale, norient  );


Gbr_q_pooled = cell(size(Gbr_q));
for orient_idx = 1 : norient
    for scale_idx = 1 : nscale
        Gbr_q_pooled{scale_idx, orient_idx} = SpaceInhibit{scale_idx, orient_idx} +...
                                              OrientInhibit{scale_idx, orient_idx} +...
                                              FreqInhibit{scale_idx, orient_idx};        
        
    end
end

%% Divisive gain control

% allocating memory for variables
r_p = cell(nscale, norient);

for orient_idx = 1 : norient
    for scale_idx = 1 : nscale
        
        r_p{scale_idx, orient_idx} = g.*( ( Gbr_p{scale_idx, orient_idx} )./...
            ( b^q + mean2(test_param) .* Gbr_q_pooled{scale_idx, orient_idx} ) );        
        
    end
end


end

%-------------------------------------------------------------------------%

function [tp_even, tp_odd ] = excitory_nonlinearity( t, p )

tp_even = cell(size(t));
tp_odd  = cell(size(t));

for i = 1 : size(t, 1)
    for j = 1 : size(t, 2)
        
        temp_real = real(t{i, j}); % even
        temp_imag = imag(t{i, j}); % odd
     
        temp_real = abs(temp_real).^p;
        temp_imag = abs(temp_imag).^p;  
        
        tp_even{i, j} = temp_real;
        tp_odd{i, j}  = temp_imag; 
    end
end

end

%-------------------------------------------------------------------------%
function out = OrientInhibitFunc( Gbr_q, OrKernelMat, sz1, sz2, nscale, norient )

out = cell(nscale, norient);
for i = 1 : nscale
    temp = [];
    for j = 1 : norient
        temp = [temp Gbr_q{i, j}(:)];
    end
   
    for j = 1 : norient
        out{i, j} = reshape( sum(temp.*OrKernelMat(:, :, j), 2), [sz1 sz2] );        
    end
end

end
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
function out =  FreqInhibitFunc( Gbr_q, FrKernelMat, sz1, sz2, nscale, norient  )

out = cell(nscale, norient);
for i = 1 : norient
    temp = [];
    for j = 1 : nscale
        temp = [temp Gbr_q{j, i}(:)];
    end
    for j = 1 : nscale
        out{j, i} = reshape( sum(temp.*FrKernelMat(:, :, j), 2), [sz1 sz2] );        
    end
end

end
%-------------------------------------------------------------------------%

