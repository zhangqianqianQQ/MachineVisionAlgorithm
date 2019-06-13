function imsegs = im2superpixels(im, method, varargin )
    if nargin < 3
        % default parameters to generate superpixels
        switch method
            case 'pedro'
                sigma = 0.8;
                k = 100;
                min_size = 150;
            case 'SLIC'
                num_superpixel = 200;
            otherwise
                error( 'unknown method to generate superpixels.' );
        end
    else
        switch method
            case 'pedro'
                para = varargin{1};
                sigma = para(1);
                k = para(2);
                min_size = para(3);
            case 'SLIC'
                num_superpixel = varargin{1};
            otherwise
                error( 'unknown method to generate superpixels.' );
        end
    end

%     prefix = num2str(floor(rand(1)*10000000));
%     fn1 = ['./tmpim' prefix '.ppm'];
%     fn2 = ['./tmpimsp' prefix '.ppm'];
%     segcmd = ['E:\playerkk\code\MATLAB\segment\segment ', num2str(seg_para(1)),... 
%         ' ', num2str(seg_para(2)), ' ', num2str(seg_para(3))];
% 
%     imwrite(im, fn1);
%     system([segcmd ' ' fn1 ' ' fn2]);
    if isa(im, 'uint8')
        im = double(im);
    end
    
    if max(im(:)) < 10
        im = double(im * 255);
    end
    
    switch method
        case 'pedro'
            segim = mexSegment(im, sigma, k, int32(min_size));
        case 'SLIC'
            segim = uint8(mexSLIC(uint32(im), num_superpixel));
        otherwise
            error( 'unknown method to generate superpixels.' );
    end
    imsegs = processSuperpixelImage(segim);
