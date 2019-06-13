function y= getYDir(N, yDirParam)
	y = yDirParam.y0;
	for i = 1:length(yDirParam.angleThresh),
		y = getYDirHelper(N, y, yDirParam.angleThresh(i), yDirParam.iter(i));
	end
end

function yDir = getYDirHelper(N, y0, thresh, iter)
% function yDir = getYDirHelper(N, y0, thresh, iter)
%Input: 
%	N: HxWx3 matrix with normal at each pixel.
%	y0: the initial gravity direction
%	thresh: in degrees the threshold for mapping to parallel to gravity and perpendicular to gravity
% 	iter: number of iterations to perform
%Output:
%	yDir: the direction of gravity vector as inferred

	nn = permute(N,[3 1 2]);     
	nn = reshape(nn,[3 numel(nn)/3]);
	nn = nn(:,~isnan(nn(1,:)));  
	
	%Set it up as a optimization problem.

	yDir = y0;
	%Let us do hard assignments
	for i = 1:iter,
		sim0 = yDir'*nn;
		indF = abs(sim0) > cosd(thresh);
		indW = abs(sim0) < sind(thresh);

		NF = nn(:,find(indF));
		NW = nn(:,find(indW));
		A = NW*NW' - NF*NF';
		b = zeros(3,1);
		c = size(NF,2);

		[V D] = eig(A);
		[gr ind] = min(diag(D));
		newYDir = V(:,ind);
		yDir = newYDir.*sign(yDir'*newYDir);
	end
end
