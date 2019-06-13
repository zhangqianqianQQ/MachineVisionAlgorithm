function [dx,dy]=   centered_gradient(input,dx,dy, nx,ny)
dx = zeros(1,round(nx*ny*+nx));
dy = zeros(1,round(nx*ny*+nx));
nx = round(nx);
ny = round(ny);
size(input);
for i = 1:ny-1
        for  j = 1:  nx-1
           k = round(i * nx + j);
           if(nx+k < length(input))
            dx(k) = 0.5*(input(k+1) - input(k-1));
            dy(k) = 0.5*(input(k+nx) - input(k-nx));
           end
        end
end
z = 1;
for  j = 2: nx-1
    
      dx(z) = 0.5*(input(z+1) - input(j-1));
        dy(z) = 0.5*(input(z+nx) - input(z));

    k = (ny - 1) * nx + z;
if(k < length(input))
        dx(k) = 0.5*(input(k+1) - input(k-1));
        dy(k) = 0.5*(input(k) - input(k-nx));
end
        z = z +1;
end
for  i = 1: ny-1
        p = (i * nx)+1;
        if(p+nx < length(input))
        dx(p) = 0.5*(input(p+1) - input(p));
        dy(p) = 0.5*(input(p+nx) - input(p-nx));
        end
        k = (i+1) * nx - 1;
if(k+nx < length(input))
        dx(k) = 0.5*(input(k) - input(k-1));
        dy(k) = 0.5*(input(k+nx) - input(k-nx));
end

  
    dx(1) = 0.5*(input(2) - input(1));
    dy(1) = 0.5*(input(nx) - input(1));

    dx(nx-1) = 0.5*(input(nx-1) - input(nx-2));
    dy(nx-1) = 0.5*(input(2*nx-1) - input(nx-1));

    dx((ny-1)*nx) = 0.5*(input((ny-1)*nx + 1) - input((ny-1)*nx));
    dy((ny-1)*nx) = 0.5*(input((ny-1)*nx) - input((ny-2)*nx));
    if(ny*nx-2 <length(input))
    dx(ny*nx-2) = 0.5*(input(ny*nx-2) - input(ny*nx-1-1-1));
    dy(ny*nx-2) = 0.5*(input(ny*nx-2) - input((ny-2)*nx-2));
    disp('at least once');
    end
    end
end