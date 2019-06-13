function img_pad=ImgPad(img_in, pad_size, op_type, varargin)
%Perform matrix border padding and the corresponding inverse transform
% Input: mat_in - the input matrix
%             pad_size - the size of padding
%             op_type - the operation type (0:padding, 1: recovering)
%             varargin: the padding method when op_type=0 
%Output: mat_out - result of the operation
% 2016-10-19 jlfeng
[nr,nc]=size(img_in);
pad_size_half=ceil(pad_size/2);
if (0==op_type)
    switch(varargin{1})
        case 0
            pad_type='symmetric';
        case 1
            pad_type='replicate';
        case 2
            pad_type='replicate';
    end
    img_pad=padarray(img_in,[pad_size_half,pad_size_half],pad_type,'both');    
elseif (1==op_type)
    img_pad=img_in(pad_size_half+1:nr-pad_size_half,pad_size_half+1:nc-pad_size_half);
else
    error('Unknown operation type.');
end