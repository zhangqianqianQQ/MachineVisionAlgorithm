function z = fillHolesV2(z)
	% function z = fillHolesV2(z)
	z0 = z;
	[h w] = size(z);
	z(isnan(z)) = inf;
	count = sum(isinf(z(:)));
	se = strel([1 1 1; 1 1 1; 1 1 1]);
	% se = strel('square', 3);
	while(count > 0),
		zf = -imdilate(-z, se);
		z(isinf(z)) = zf(isinf(z));
		count = sum(isinf(z(:)));
	end
end
