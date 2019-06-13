function [res] = make_csf(x, y, nfreq)
[xplane,yplane]=meshgrid(-x/2+0.5:x/2-0.5, -y/2+0.5:y/2-0.5);	% generate mesh
plane=(xplane+1i*yplane)/y*2*nfreq;
radfreq=abs(plane);				% radial frequency

% We modify the radial frequency according to angle.
% w is a symmetry parameter that gives approx. 3 dB down along the
% diagonals.
w=0.7;
s=(1-w)/2*cos(4*angle(plane))+(1+w)/2;
radfreq=radfreq./s;

% Now generate the CSF
csf = 2.6*(0.0192+0.114*radfreq).*exp(-(0.114*radfreq).^1.1);
f=find( radfreq < 7.8909 ); csf(f)=0.9809+zeros(size(f));

res = csf;
end