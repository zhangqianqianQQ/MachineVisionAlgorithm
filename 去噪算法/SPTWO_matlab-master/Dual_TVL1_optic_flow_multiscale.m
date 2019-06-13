function Dual_TVL1_optic_flow_multiscale(I0,I1,u1,u2,height,width,params)
size = height * width;
tau = params.tau;
    lambda = params.lambda; 
    theta = params.theta; 
   nscales = params.nscales; 
    zfactor = params.zfactor; 
 warps = params.warps;  
   epsilon = params.epsilon; 
     verbose = params.verbose; 
  iflagMedian = params.iflagMedian;
  u1s = cell(1,round(nscales));
  u2s = cell(1,round(nscales));
   u1s{1,1} = u1;
   
    u2s{1,1} = u2;
    nx  = width;
    ny  = height;
    I0s = {imgaussfilt(I0,0.8)};
    I1s = {imgaussfilt(I1,0.8)};
    
    for s = 2: nscales - 1
        [nx(s),ny(s)]=  zoom_size(nx(s-1), ny(s-1),  zfactor);
        sizes = nx(s) * ny(s);
       
         I0s{s} = zoom_out(I0s{s-1},  nx(s-1), ny(s-1), zfactor)
          I1s{s} = zoom_out(I1s{s-1},  nx(s-1), ny(s-1), zfactor)
    end
     for  i = 1: (nx(nscales-1) * ny(nscales-1))-1
        u1s{nscales-1,i} = 0.0;
        u2s{nscales-1,i} = 0.0;
         for s = nscales-1:-1: 1
        if (verbose)
            disp( "Scale "+ s+ ": "+nx(s)+" " +ny(s) + "\n" );
            
        end
        
         Dual_TVL1_optic_flow(I0s{s}, I1s{s}, u1s(s), u2s(s), nx(s), ny(s),tau, lambda, theta, warps, epsilon, verbose, iflagMedian);

       
        if (~s) break;
        end

       

      
            
if s > 1
                u1s{1,s-1} = zoom_in(u1s(1,s), nx(s), ny(s), nx(s-1), ny(s-1));
            

           
               u2s{1,s-1} = zoom_in(u2s(1,s), nx(s), ny(s), nx(s-1), ny(s-1));
       %not implemented yet%
end
         
        
         end
     
     end
    
end