function sigma_sq = noise_sigma_sq(w)
[n m]=size(w);
w1=w(((n/2)+1):n,((m/2)+1):m);
c=median(abs(w1(:)))/0.6745;
sigma_sq=c^2;
end