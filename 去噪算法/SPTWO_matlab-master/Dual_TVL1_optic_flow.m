function Dual_TVL1_optic_flow( I0,I1,     u1, u2, nx, ny,     tau,    lambda, theta,   warps,  epsilon,verbose,iflagMedian)
size = round(nx * ny);
l_t = lambda * theta;
if isa(u1,'cell') && isa(u2,'cell')
   u1 = cell2mat(u1);
   u2 = cell2mat(u2);
end
MAX_ITERATIONS= 300;
PRESMOOTHING_SIGMA =0.8;
GRAD_IS_ZERO = 1E-10;
[I1x, I1y] = centered_gradient(I1, 0, 0, nx, ny);
  for  i = 1: size 
        p11(i) =0.0; 
        p12(i) = 0.0;
        p21(i) =0.0;
        p22(i) = 0.0;
  end
  rho_c = zeros(1,size);
  grad = zeros(1,size);
  for  warpings = 1: warps
      I1w = bicubic_interpolation_warp(I1,  u1, u2, 0,  nx, ny, 1);
      I1wx =  bicubic_interpolation_warp(I1x, u1, u2, 0, nx, ny, 1);
     I1wy = bicubic_interpolation_warp(I1y, u1, u2, 0, nx, ny, 1);
      for  i = 1:size
           Ix2 = I1wx(i) * I1wx(i);
             Iy2 = I1wy(i) * I1wy(i);

            
            grad(i) = (Ix2 + Iy2);
             sizes = [length(u2),length(I1w),length(I1wx),length(u1),length(I1wy),length(I0)];
if i <= min(sizes)
            rho_c(i) = (I1w(i) - I1wx(i) * u1(i)- I1wy(i) * u2(i) - I0(i));
end
      end
     n = 0;
       error = Inf;
        while (error > epsilon * epsilon && n < MAX_ITERATIONS) 
            n = n +1;
           

            for  i = 1 : size
                 sizes = [length(u2),length(I1w),length(I1wx),length(u1),length(I1wy),length(I0)];
if i <= min(sizes)
               rho = rho_c(i)+ (I1wx(i) * u1(i) + I1wy(i) * u2(i));

               d1 = 0.0;  d2 = 0.0;

                if (rho < - l_t * grad(i)) 
                    d1 = l_t * I1wx(i);
                    d2 = l_t * I1wy(i);
                 else 
                    if (rho > l_t * grad(i)) 
                        d1 = -l_t * I1wx(i);
                        d2 = -l_t * I1wy(i);
                     else 
                        if (grad(i) < GRAD_IS_ZERO)
                            d1 = 0;
                            d2 = 0;
                        else 
                             fi = -rho/grad(i);
                            d1 = fi * I1wx(i);
                            d2 = fi * I1wy(i);
                        end
                        
                    end
                end
end
if(i <= length(u1))
                v1(i) = u1(i) + d1;
end
if(i <= length(u2))
                v2(i) = u2(i) + d2;
end
            end
           div_p1 =  divergence(p11, p12, 0, nx ,ny);
           div_p2 = divergence(p21, p22, 0, nx ,ny);
            error = 0.0;


            for  i = 1:  size-1
                if(i <= length(u1))
                u1k = u1(i);
                u2k = u2(i);

                u1(i) = v1(i) + theta * div_p1(i);
                u2(i) = v2(i) + theta * div_p2(i);

                error = error + (u1(i) - u1k) * (u1(i) - u1k) +(u2(i) - u2k) * (u2(i) - u2k);
                end
            end
            error =  error / size;
           [u1x, u1y ] = forward_gradient(u1, 0, 0, nx ,ny);
           [u2x, u2y] =  forward_gradient(u2, 0, 0, nx ,ny);
          for (i = 1:  size-1) 
                 taut = tau / theta;
                 if i < length(u1x)
                g1   = hypot(u1x(i), u1y(i));
                g2   = hypot(u2x(i), u2y(i));
                 end
               ng1  = 1.0 + taut * g1;
                 ng2  = 1.0 + taut * g2;

                p11(i) = (p11(i) + taut * u1x(i)) / ng1;
                p12(i) = (p12(i) + taut * u1y(i)) / ng1;
                p21(i) = (p21(i) + taut * u2x(i)) / ng2;
                p22(i) = (p22(i) + taut * u2y(i)) / ng2;
          end

        end
  
        %applay the filter and continue 
end