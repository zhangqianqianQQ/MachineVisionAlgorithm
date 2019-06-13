function R = getRMatrix(yi, yf)
	yi = yi./norm(yi);
	yf = yf./norm(yf);

	%Find angle of rotation
	phi = acosd(abs(yi'*yf));
	if(abs(phi) > 0.1),
		ax = cross(yi,yf);
		ax = ax./norm(ax);
		phi = phi*(pi/180);
		S_hat = [ 0 -ax(3) ax(2); ax(3) 0 -ax(1);-ax(2) ax(1) 0];
		R = eye(3) + sin(phi)*S_hat + (1-cos(phi))*(S_hat^2);
	else
		R = eye(3,3);
	end
end
