function Iout = zoom_in(I,nx,ny,nxx,nyy)
factorx = (nxx / nx);
factory = (nyy / ny);
 for  i1 = 1: nyy-1
            for  j1 = 1:  nxx-1
               i2 =   i1 / factory;
                j2 =   j1 / factorx;

                 g = bicubic_interpolation_at(I, j2, i2, nx, ny, false,0);
                Iout(round(i1 * nxx + j1)) = g;
            end
 end
end