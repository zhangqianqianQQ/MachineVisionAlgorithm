% Runs a step of non-local Bayes
%
% USAGE: [deno, aggw] = nlbayes_step(nisy, bsic, sigma, prms)
%
%  -> nisy    : noisy image
%  -> bsic    : basic estimate (can be empty for the first step)
%  -> sigma   : noise std. dev.
%  -> prms    : struc with prms (wx, px, np, r)
%
%  <- deno    : denoised image
%  <- aggw    : aggregation weights
function [deno, aggw] = nlbayes_step(nisy, bsic, sigma, prms)

% image size and channels
w = size(nisy,2);
h = size(nisy,1);
chnls = size(nisy,3);

% in the absence of the basic estimate, define basic as the noisy image
if isempty(bsic),
	bsic = nisy;
	step2 = false;
else
	step2 = true
end

% aggregation
aggw = zeros(size(nisy)); % aggregation weights
aggp = zeros(size(nisy)); % mask of already processed patches (for speed-up trick)
aggu = zeros(size(nisy)); % aggregated image
deno = zeros(size(nisy)); % denoised image (deno = aggu ./ aggw);

% step sizes
stepx = floor(prms.px/2);
stepy = floor(prms.px/2);
ii = 0; % iteration counter

% patch dimensionality
pdim = prms.px * prms.px * chnls;

% use dct basis
% U = kron(eye(chnls), dct_basis(prms.px, prms.px));
% use pca basis
U = [];

% use an aggregation window
if prms.pw,
	wx = chebwin(prms.px);
else
	wx = ones(prms.px,1);
end
wwx = repmat(reshape(wx*wx',[prms.px*prms.px 1]),[chnls prms.np]);

% main loop
for pay = [1:stepy:h - prms.px+1,h - prms.px+1],
for pax = [1:stepx:w - prms.px+1,w - prms.px+1], ii = ii + 1;

	% acceleration: skip iteration if patch has been been already denoised
	if aggp(pay,pax,1),
		continue;
	end

	% -------------------------------------------------- compute patch group

	% patches in search region
	srch_region = bsic(max(1,pay - prms.wx):min(h,pay + prms.wx + prms.px - 1),...
	                   max(1,pax - prms.wx):min(w,pax + prms.wx + prms.px - 1),:);

	srch_patches = im2col_ch(srch_region, [prms.px prms.px]);
	refe_patch = bsic(pay:pay+prms.px-1,pax:pax+prms.px-1,:);

	[distances, idx] = sort(L2_distance(refe_patch(:), srch_patches));

	% coordinates of the np nearest neighbors to the ref patch
	idx = idx(1:prms.np)';

	srch_h = size(srch_region,1) - prms.px + 1;
	patches.coords = [max(1,pax - prms.wx) + floor((idx-1)/srch_h),...
	                  max(1,pay - prms.wx) +   mod( idx-1 ,srch_h)];


	% ---------------------------------------------- extract similar patches
	if step2,
		patches.bsic = srch_patches(:,idx);

		% extract noisy patches
		srch_region = nisy(max(1,pay - prms.wx):min(h,pay + prms.wx + prms.px - 1),...
		                   max(1,pax - prms.wx):min(w,pax + prms.wx + prms.px - 1),:);
		patches.nisy = im2col_ch(srch_region, [prms.px prms.px]);
		patches.nisy = patches.nisy(:,idx);
	else
		patches.nisy = srch_patches(:,idx);
	end


	% ----------------------------------------------- compute bayes estimate
	if step2,
		aa = reshape(patches.bsic,[pdim prms.np]);
		[dd,gg] = compute_bayes_estimate(patches.nisy,aa,sigma,prms.r,'pos',U);
	else
		[dd,gg] = compute_bayes_estimate(patches.nisy,[],sigma,prms.r,'pos',U);
	end

	% ------------------------------------------- aggregate patches on image
	gg = ones(size(dd,1),1)*gg;
	aggu = aggregate_patches(aggu, wwx.*gg.*dd, [prms.px prms.px], patches.coords);
	aggw = aggregate_patches(aggw, wwx.*gg    , [prms.px prms.px], patches.coords);

	aggp(patches.coords(:,2) + (patches.coords(:,1)-1)*h) = 1+...
	           aggp(patches.coords(:,2) + (patches.coords(:,1)-1)*h);

	% draw
	if (mod(ii,50) == 1)
		nonzero = find(aggw ~= 0);
		deno(nonzero) = min(255, max(0, aggu(nonzero) ./ aggw(nonzero)));

		% draw a red box indicating limits of search region
		deno(max(1,pay-prms.wx):min(h,pay+prms.wx),max(1,pax-prms.wx),:) = 0;
		deno(max(1,pay-prms.wx):min(h,pay+prms.wx),min(w,pax+prms.wx),:) = 0;
		deno(max(1,pay-prms.wx),max(1,pax-prms.wx):min(w,pax+prms.wx),:) = 0;
		deno(min(h,pay+prms.wx),max(1,pax-prms.wx):min(w,pax+prms.wx),:) = 0;
		deno(max(1,pay-prms.wx):min(h,pay+prms.wx),max(1,pax-prms.wx),1) = 255;
		deno(max(1,pay-prms.wx):min(h,pay+prms.wx),min(w,pax+prms.wx),1) = 255;
		deno(max(1,pay-prms.wx),max(1,pax-prms.wx):min(w,pax+prms.wx),1) = 255;
		deno(min(h,pay+prms.wx),max(1,pax-prms.wx):min(w,pax+prms.wx),1) = 255;

		imagesc(max(min([deno;255-aggw],255),0)/255,[0 1]);
		axis equal, axis off,
		colormap gray
		drawnow
		pause(.01)

		% reset red pixels to 0
		deno(max(1,pay-prms.wx):min(h,pay+prms.wx),max(1,pax-prms.wx),1) = 0;
		deno(max(1,pay-prms.wx):min(h,pay+prms.wx),min(w,pax+prms.wx),1) = 0;
		deno(max(1,pay-prms.wx),max(1,pax-prms.wx):min(w,pax+prms.wx),1) = 0;
		deno(min(h,pay+prms.wx),max(1,pax-prms.wx):min(w,pax+prms.wx),1) = 0;
	end

end
end

% compute denoised image
nonzero = find(aggw ~= 0);
deno(nonzero) = min(255, max(0, aggu(nonzero) ./ aggw(nonzero)));

end

