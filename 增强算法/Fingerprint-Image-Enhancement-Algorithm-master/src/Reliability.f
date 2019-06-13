function reliability = reliability_f(G_xx, G_yy, G_xy, cos2theta, sin2theta, denom)
 
    Imin = (G_yy+G_xx)/2 - (G_xx-G_yy).*cos2theta/2 - G_xy.*sin2theta/2;
    Imax = G_yy+G_xx - Imin;
    
    reliability = 1 - Imin./(Imax+.001);
        
