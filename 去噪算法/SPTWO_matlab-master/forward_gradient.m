function [fx,fy] = forward_gradient(f,fx,fy, nx, ny)
 
for  i = 1: ny-2
        

         
          for j = 0: nx-2
                p  = i * nx + j;
                p1 = p + 1;
                p2 = p + nx;
if p <= length(f)
                fx(round(p)) = f(round(p1)) - f(round(p));
                fy(round(p)) = f(round(p2)) - f(round(p));
end
          end
end



   
    for ( j = 1: nx-2) 
         p = round((ny-1) * nx + j);
if(p < length(f))
        fx(p) = f(p+1) - f(p);
        fy(p) = 0;
end

 
    for  i = 1: ny-1 
      p = i * nx-1;
if((p <= length(f)) && (p > 0))
    if(p <= length(fx) && p <= length(fy))
        
        fx(round(p)) = 0;
        if( p+nx <= length(f))
        fy(round(p)) = (f(round(p+nx)) - f(round(p)));
        end
    end
    end
    end
    fx(round(ny * nx - 1)) = 0;
    fy(round(ny * nx - 1)) = 0;
end