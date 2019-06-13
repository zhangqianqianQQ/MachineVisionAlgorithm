function div = divergence( v1,v2,div,  nx,    ny)

 for ( i = 1:ny-2)
        

           

            for( j = 1 :nx-2) 
                p  = i * nx + j;
                p1 = p - 1;
                p2 = p - nx;

                v1x = v1(round(p)) - v1(round(p1));
                v2y = v2(round(p)) - v2(round(p2));

                div(round(p)) = v1x + v2y;
            end
 end
 k = 1;
 for ( j = 1:nx-2) 
     
        p = (ny-1) * nx + j;

        div(j) = v1(j) - v1(k) + v2(j);
        div(round(p)) = v1(round(p)) - v1(round(p)-1) - v2(round(p-nx));
        k = k +1;
 end

    
    for  i = 1:ny-2 
         p1 = i * nx;
         p2 = (i+1) * nx - 1;

        div(round(p1)) =  v1(round(p1))   + v2(round(p1)) - v2(round((p1 - nx)+1));
        div(round(p2)) = -v1(round(p2)-1) + v2(round(p2)) - v2(round(p2 - nx));

    end

    div(1)         =  v1(1) + v2(1);
    div(round(nx)-1)      = -v1(round(nx) - 2) + v2(round(nx) - 1);
    if((round(ny)-1)*round(nx) <= length(v1))
    div((round(ny)-1)*round(nx)) =  v1((round(ny)-1)*round(nx)) - v2((round(ny)-2)*round(nx));
    div(round(ny*nx-1))   = -v1(round(ny*nx - 2)) - v2(round((ny-1)*nx - 1));
    end
end