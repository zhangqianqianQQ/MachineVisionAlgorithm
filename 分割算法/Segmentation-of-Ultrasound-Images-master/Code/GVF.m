function [u,v] = GVF(f, mu, ITER)
%-----------------GVF Compute gradient vector flow.---------- 


[fx,fy] = gradient(f); 
u = fx; v = fy;    
SqrMagf = fx.*fx + fy.*fy; 

   
% Iteratively solve for the GVF u,v
for i=1:ITER

  u = u + 4*mu*del2(u) - SqrMagf.*(u-fx);  
  v = v + 4*mu*del2(v) - SqrMagf.*(v-fy);  

  fprintf(1, '%3d', i);
  if (rem(i,20) == 0)
     fprintf(1, '\n');
  end 
end
fprintf(1, '\n');


