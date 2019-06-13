% A patch group is a matrix pg of size
%
%     px x px x ch x pt x np
%
% where px is the spatial  size of the patch
%       pt is the temporal size of the patch
%       ch is the number of channels
%       np is the number of patches in the group
% 
% This function transforms the patch group in to 
% an RGB image with all the patches in the group, 
% of size
%
%     pt*(px+sw)-sw x np*(px+sw)-sw x ch
%
% The temporal slices of the patch are stacked vertically,
% with separators of sw pixels. Each patch is then stacked 
% horizontally, also with separators of sw pixels.
%
% This function was written to use from patch_group.
%
function pp = build_patch_image(pp, force_one_row, sc, sw)

px = size(pp,1);
pt = size(pp,4);
np = size(pp,5);

if nargin < 2,
	force_one_row = false;
end

if nargin < 3,
	sc = 255;
end

if nargin < 4,
	sw = 1;
end


if (size(sc,2) ~= 1) && (size(sc,2) ~= 3),
	error('The separator colormap should have either 1 or 3 channels')
end

ch = max(size(pp,3),size(sc,2));

if (max(size(sc)) == 1), 

	pp = permute(pp, [2 1 4 5 3]);
	pp = cat(2, pp, 0*sc*ones(px, sw, pt, np, ch));
	pp = reshape(pp, [px, pt*(px + sw), np, ch]);

	pp = permute(pp, [2 1 3 4]);
	pp = cat(2, pp, sc*ones(pt*(px + sw), sw, np, ch));
	pp = reshape(pp, [pt*(px + sw), np*(px + sw), ch]);

	pp = pp(1:pt*(px + sw) - sw, 1:np*(px + sw) - sw, :);


	% if resulting image is too long and narrow, split it in more rows
	if (force_one_row == false) && (10*pt < np)

		% factorize np into m*n minimizing the perimeter m+n
		m = floor(sqrt(np));
		while mod(np,m) ~= 0,
			m = m - 1;
		end
		n = np/m;

		if (10*m*pt < n)
			m = floor(sqrt(np));
			n = ceil(np/m);
		end

		% separator between rows of patches has to be wider than separator between 
		% the frames of a patch
		swr = sw * (1 + (pt > 1));
		ppp = sc*ones(m*(pt*(px + sw) - sw + swr) - swr, n*(px + sw) - sw, ch); 
		for i = 0:m-1,

			start_pp  = i*n*(px + sw) + 1;
			until_pp  = min(i*n*(px + sw) + n*(px + sw) - sw, size(pp,2));
			range_ppp = i*(pt*(px + sw) - sw + swr) + [1:pt*(px + sw) - sw];
			ppp(range_ppp,1:1+until_pp - start_pp,:) = pp(:,start_pp:until_pp,:);

		end

		pp = ppp;

	end

else

	m = 1;

	% if resulting image is too long and narrow, split it in more rows
	if (force_one_row == false) && (10*pt < np)

		% factorize np into m*n minimizing the perimeter m+n
		m = floor(sqrt(np));
		while mod(np,m) ~= 0,
			m = m - 1;
		end

	end

	n = np/m;

	if size(sc,2) < ch, sc = repmat (sc, [1  1 ch]);
	else                sc = reshape(sc, [np 1 ch]);
	end

	if size(pp,3) < ch, pp = repmat(pp,[1 1 ch]);
	end

	ppp = zeros(m*(pt*(px + sw) + sw),n*(px + 2*sw), ch);
	for i = 1:np,

		scp = sc(i,:,:);

		p = pp(:,:,:,:,i);
		p = permute(p, [2 1 4 5 3]);
		sep = zeros([px, sw, pt, 1, ch]);
		p = cat(2, p, repmat(reshape(scp,[1, 1, 1, 1, ch]), px, sw, pt));
		p = squeeze(reshape(p, [px, pt*(px + sw), 1, ch]));

		% usando cat, agregar bordes derecho, izq, y superior
		p = permute(p, [2 1 3]);
		p = cat(1, repmat(scp, sw, px), p);
		p = cat(2, repmat(scp, pt*(px+sw) + sw, sw), p);
		p = cat(2, p, repmat(scp, pt*(px+sw) + sw, sw));

		[ni,mi] = ind2sub([n,m],i);
		ppp((mi-1)*size(p,1) + [1:size(p,1)],...
		    (ni-1)*size(p,2) + [1:size(p,2)],:) = p;

	end

	pp = ppp;

end
