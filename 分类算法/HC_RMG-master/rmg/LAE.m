function z = LAE(x,U,cn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% LAE (Local Anchor Embedding)
% Written by Wei Liu (wliu@ee.columbia.edu)
% x(dX1): input data vector 
% U(dXs): anchor data matrix, s: the number of closest anchors 
% cn: the number of iterations, 5-20
% z: the s-dimensional coefficient vector   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[d,s] = size(U);
z0 = ones(s,1)/s; %(U'*U+1e-6*eye(s))\(U'*x); % % %
z1 = z0; 
delta = zeros(1,cn+2);
delta(1) = 0;
delta(2) = 1;
beta = zeros(1,cn+1);
beta(1) = 1;

for t = 1:cn
    alpha = (delta(t)-1)/delta(t+1);
    v = z1+alpha*(z1-z0); %% probe point
    
    dif = x-U*v;
    gv =  dif'*dif/2;
    clear dif;
    dgv = U'*U*v-U'*x;
    %% seek beta
    for j = 0:100
        b = 2^j*beta(t);
        z = SimplexPr(v-dgv/b);
        dif = x-U*z;
        gz = dif'*dif/2;
        clear dif;
        dif = z-v;
        gvz = gv+dgv'*dif+b*dif'*dif/2;
        clear dif;
        if gz <= gvz
            beta(t+1) = b;
            z0 = z1;
            z1 = z;
            break;
        end
    end
    if beta(t+1) == 0
        beta(t+1) = b;
        z0 = z1;
        z1 = z;
    end
    clear z;
    clear dgv;
    delta(t+2) = ( 1+sqrt(1+4*delta(t+1)^2) )/2;
    
    %[t,z1']
    if sum(abs(z1-z0)) <= 1e-4
        break;
    end
end
z = z1;
clear z0;
clear z1;
clear delta;
clear beta;

