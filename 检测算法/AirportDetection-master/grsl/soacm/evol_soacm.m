%  The soacm code is modified on the basis of an implementation of C-V model, which is:
%  created on 04/26/2004
%  author: Chunming Li
%  email: li_chunming@hotmail.com
%  Copyright (c) 2004-2006 by Chunming Li
function phi = evol_soacm(ort,img,phi_init,mu,nu,lambda_1,lambda_2,delta_t,epsilon)

    img = mirror_expand(img); 
    
    phi = mirror_expand(phi_init); 
    phi = mirror_ensure(phi);
    delta_h = Delta(phi,epsilon);
    cur = curvature(phi); % compute curvature of phi function
    [gray_c1,gray_c2] = binaryfit(phi,img,epsilon);
    
    if ort == -1 
        t1 = lambda_1 * (img-gray_c1).^2;
        t2 = lambda_2 * (img-gray_c2).^2; 
        phi = phi + delta_t * delta_h .* ( mu*cur - nu - t1 + t2);
    else
        t3 = (img-ort).^2;
        phi = phi + delta_t * delta_h .* ( mu*cur - nu - t3);
    end
    
    phi = mirror_shrink(phi);
end