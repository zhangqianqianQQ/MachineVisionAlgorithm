% Multichannel version of im2col. Rearranges image blocks into columns.
% The vectorized blocks of each channel are staked vertically in the output.
%
% USAGE: patches = im2col_ch(im, [ph pw], mode)
%
%  -> im      : input image
%  -> ph,pw   : patch size (ph x pw)
%  -> mode    : either 'distinct' of 'sliding'
%
%  <- patches : output patches (ph pw ch x n)
function patches = im2col_ch(im, psz, mode)

	if nargin < 3,
		mode = 'sliding';
	end

	pdim = prod(psz);
	ch = size(im,3);

	% extract patches from first channel
	patches = im2col(im(:,:,1),psz,mode);

	% number of patches
	n = size(patches,2);

	% allocate room for the other channels
	patches = [patches ; zeros((ch-1)*size(patches,1), size(patches,2))];
	for c = 2:ch,
		patches((c-1)*pdim + [1:pdim],:) = im2col(im(:,:,c), psz, mode);
	end

end


