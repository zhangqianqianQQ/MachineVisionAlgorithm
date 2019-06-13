function u = FBS_ATV(g, SB_mu)
% FBS algorithms for Non-convex Anisotropic Total Variation denoising
%
%   u = arg min_u 1/2||u-f||_2^2 + mu*NATV(u)
%
% Refs:
%  *Jian Zou, Total Variation Denoising with Non-convex Regularizations
%   
%
% Jian Zou
% School of Information and Mathematics
% Yangtze University 
% zoujian@yangtzeu.edu.cn

f = g(:);
n = length(f);
MAX_ITER = 10000;
TOL_STOP = 1e-3;
lambda = 32;       
alpha = 0.8/lambda;

gamma = alpha*lambda;
mu = 1.9/ ( max( 1,  gamma / (1-gamma) ) );



% initialization
u = zeros(n,1);
x = zeros(n,1);

iter = 0;
old_u = u;
delta_u = inf;
tol = 1e-3;
while delta_u > TOL_STOP 
    iter = iter + 1;
    fprintf('FBS_it. %g \n',iter);
    
    
    % update w v
    w = u - mu * ( (1 - gamma) * u + gamma * x - f);
    v = x - mu *  gamma * (x - u) ;
    
    % update u x
    u = SB_ATV(w, SB_mu);
    x = SB_ATV(v, SB_mu);
    
    delta_u = max(abs( u(:) - old_u(:) )) / max(abs(old_u(:)));
    old_u = u;   
    fprintf('err=%g \n',delta_u);
end



fprintf('Stopped because norm(u-old_u)/norm(u) <= tol=%.1e\n',tol);
end
