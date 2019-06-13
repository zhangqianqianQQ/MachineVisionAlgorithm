function [deno, aggw, mean_nisy, U, S] = compute_bayes_estimate(nisy, bsic, sigma, rank, filter_type, U)

if nargin < 5,
	filter_type = 'pos';
end

if nargin < 6,
	U = [];
end

d = size(nisy,1);
n = size(nisy,2);

sigma_bsic = 0;
if isempty(bsic),
	bsic = nisy;
	sigma_bsic = sigma;
end

% center
mean_nisy = mean(nisy, 2);
mean_bsic = mean(bsic, 2);
nisy = nisy - mean_nisy*ones(1,n);
bsic = bsic - mean_bsic*ones(1,n);

if isempty(U),
	% covariance matrix
	C = 1/n*bsic*bsic';

	% redefine rank as...
	if (rank >= 0), rank = min(rank, n-1);
	else            rank = min(d   , n-1);
	end

	% eigendecomposition
	if rank > 0 && rank < d-1,
		[U,S] = eigs(C,rank);
	else
		[U,S] = eig(C);
	end

	U = real(U);
	S = real(diag(S));
else
	% project data vectors onto basis
	S = mean((U'*bsic).^2,2);
end


% sort basis according to variance
if rank > 0 && rank <= d,
	tmp = sortrows([ S U'],-1);
	S = tmp(:,1);
	U = tmp(:,2:end)';
end

% wiener filter coefficients
if     strcmp(filter_type, 'pos'), 

	W = min(max( 0  , S - sigma_bsic*sigma_bsic),Inf);
	W = diag(1./(1 + sigma*sigma ./ W));

elseif strcmp(filter_type, 'neg'),

	W = min(max(-Inf, S - sigma_bsic*sigma_bsic),Inf);
	W = diag(1./(1 + sigma*sigma ./ W));

elseif strcmp(filter_type, 'neg-inv'),

	W = min(max(-Inf, S - sigma_bsic*sigma_bsic),Inf);
	W = abs(diag(1./(1 + sigma*sigma ./ W)));

end

% denoise group
comp = U'*nisy;
deno = (U*W)*comp + mean_nisy*ones(1,n);

% compute aggregation weights
beta = 2;
maha = mean(comp.^2.*(min((1./S),1/sigma/sigma)*ones(1,n)));
aggw = maha;
%aggw = exp(-maha/2/beta);

