function output = bicubic_interpolation_at(input,uu,vv,nx,ny,border_out,BOUNDARY_CONDITION)
output = 0.0;
sx = 0;
sy = 0;
if(uu < 0)
    sx = -1;
else
    sx = 1;
end
if(vv < 0)
    sy = -1;
else
    sy = 1;
end
out = 0;

switch(BOUNDARY_CONDITION)
    case 0
          [out,x]   = neumann_bc(uu, nx);
         [out,y]   = neumann_bc(vv, ny);
         [out,mx]  = neumann_bc(uu - sx, nx);
         [out,my]  = neumann_bc(vv - sx, ny);
         [out,dx]  = neumann_bc( uu + sx, nx);
         [out,dy]  = neumann_bc( vv + sy, ny);
         [out,ddx] = neumann_bc( uu + 2*sx, nx);
         [out,ddy] = neumann_bc( vv + 2*sy, ny);
    case 1
        [out,x]   =periodic_bc(uu, nx);
         [out,y]   = periodic_bc(vv, ny);
         [out,mx]  = periodic_bc(uu - sx, nx);
         [out,my]  = periodic_bc(vv - sx, ny);
         [out,dx]  = periodic_bc( uu + sx, nx);
         [out,dy]  = periodic_bc( vv + sy, ny);
         [out,ddx] = periodic_bc( uu + 2*sx, nx);
         [out,ddy] = periodic_bc( vv + 2*sy, ny);
    case 2
         [out,x]  = symmetric_bc(uu, nx);
         [out,y]   = symmetric_bc(vv, ny);
         [out,mx]  = symmetric_bc(uu - sx, nx);
         [out,my]  = symmetric_bc(vv - sx, ny);
         [out,dx]  = symmetric_bc( uu + sx, nx);
         [out,dy]  = symmetric_bc( vv + sy, ny);
         [out,ddx] = symmetric_bc( uu + 2*sx, nx);
         [out,ddy] = symmetric_bc( vv + 2*sy, ny);
    otherwise
        [out,x]   = neumann_bc(uu, nx);
         [out,y]   = neumann_bc(vv, ny);
         [out,mx]  = neumann_bc(uu - sx, nx);
         [out,my]  = neumann_bc(vv - sx, ny);
         [out,dx]  = neumann_bc( uu + sx, nx);
         [out,dy]  = neumann_bc( vv + sy, ny);
         [out,ddx] = neumann_bc( uu + 2*sx, nx);
         [out,ddy] = neumann_bc( vv + 2*sy, ny);
         if((out == 1) && (border_out == 0))
             
             output = 0.0;
         else
            p11 = input(mx  + nx * my);
         p12 = input(x   + nx * my);
          p13 = input(dx  + nx * my);
          p14 = input(ddx + nx * my);

          p21 = input(mx  + nx * y);
          p22 = input(x   + nx * y);
          p23 = input(dx  + nx * y);
          p24 = input(ddx + nx * y);

          p31 = input(mx  + nx * dy);
          p32 = input(x   + nx * dy);
          p33 = input(dx  + nx * dy);
          p34 = input(ddx + nx * dy);

          p41 = input(mx  + nx * ddy);
          p42 = input(x   + nx * ddy);
          p43 = input(dx  + nx * ddy);
          p44 = input(ddx + nx * ddy);
             pol = [p11, p21, p31, p41;
            p12, p22, p32, p42;
            p13, p23, p33, p43;
            p14, p24, p34, p44];
      output =   bicubic_interpolation_cell(pol, uu-x, vv-y);
         end
         
end