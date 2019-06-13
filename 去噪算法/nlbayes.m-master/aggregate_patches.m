% Aggregates a set of n patches of size hxw with ch channels over an image
%
% USAGE: agg_out = aggregate_patches(agg_in, patches, [ph pw], coordinates)
%
%  -> agg_in      : input aggregation image
%  -> patches     : set of patches (h*w*ch x n)
%  -> [ph,pw]     : patch size
%  -> coordinates : (x,y) coordinates of top left pixel of each patch (n x 2)
%
%  <- agg_out     : output aggretation image
function agg = aggregate_patches(agg, patches, psz, cc)

	ph = psz(1); pw = psz(2);

	% number of patches
	n = size(cc,1);

	patches = reshape(patches, [psz(:)' size(agg,3) n]);

	for i = 1:n,

		agg(cc(i,2):cc(i,2)+ph-1,...
		    cc(i,1):cc(i,1)+pw-1,:) = patches(:,:,:,i) ...
		                            + agg(cc(i,2):cc(i,2)+ph-1,...
		                                  cc(i,1):cc(i,1)+pw-1,:);

	end
end

