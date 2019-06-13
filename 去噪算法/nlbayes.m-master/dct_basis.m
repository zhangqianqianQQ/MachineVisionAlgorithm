% Builds a DCT basis.
%
% USAGE: U = dct_basis(w,h,f)
%
%  -> w, h, f: dimensions of the 3D signal
%
%  <- U      : matrix with the dct basis as columns (whf x whf)
function U = dct_basis(px,py,pt)

if nargin < 3,
	pt  = 1;
end

% build DCT basis
cx = cos((1/2 + [0:px-1]') * [0:px-1]*pi/px);
cy = cos((1/2 + [0:py-1]') * [0:py-1]*pi/py);
ct = cos((1/2 + [0:pt-1]') * [0:pt-1]*pi/pt);

cx(:,1) = cx(:,1  ) / sqrt(px);
cy(:,1) = cy(:,1  ) / sqrt(py);
ct(:,1) = ct(:,1  ) / sqrt(pt);
cx(:,2:px) = cx(:,2:px) * sqrt(2/px);
cy(:,2:py) = cy(:,2:py) * sqrt(2/py);
ct(:,2:pt) = ct(:,2:pt) * sqrt(2/pt);

U = zeros(px*py*pt, px*py*pt);

for k = 1:pt,
for i = 1:py,
for j = 1:px,

	u = cy(:,i)*cx(:,j)';
	u = u(:)*ct(:,k)';
	U(:,(k-1)*px*py + (i-1)*px + j) = u(:);

end
end
end

