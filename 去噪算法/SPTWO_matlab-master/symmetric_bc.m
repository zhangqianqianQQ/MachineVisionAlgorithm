function [out,x] =  symmetric_bc( x, nx)

    if(x < 0) 
   border = nx - 1;
       xx = -x;
        n  = mod((xx/border) , 2);

        if ( n ) x = border - (mod( xx ,border) );
        else x = mod(xx , border);
        out = 1;
        end
        elseif ( x >= nx ) 
         border = nx - 1;
         n = mod((x/border) , 2);
        end
        if ( n ) x = border - ( mod(x , border) );
        else x = mod(x , border);
        out = 1;
    


        end
end
        