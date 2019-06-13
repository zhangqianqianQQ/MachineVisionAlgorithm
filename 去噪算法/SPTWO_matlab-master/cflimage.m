classdef cflimage
%    Created by Sofiane Khoudour 
%    All inputs should be a struct 
%    and the constructor versions 
%    are the cases of the switch
    
    properties
        d_c=0; d_w=0; d_h=0; d_wh=0; d_whc = 0;
        name = "char";
       visuMin = 0.0;
       visuMax = 0.0;
       
    end
    
    methods
        function obj = cflimage(nargument,arg)
            switch nargument
                case 0
                     d_c = 0; 
           d_w = 0; d_h = 0; d_wh = 0;  d_whc = 0;  d_v = 0;  visuMin = 0.0; visuMax = 255.0;
         
                case 3
                      d_c = arg.c;   d_w = arg.w; d_h = arg.h; d_wh = arg.w*arg.h;  d_whc = arg.c*arg.w*arg.h;  d_v = zeros(1,arg.c*arg.w*arg.h);  visuMin = 0.0; visuMax = 255.0;
             
           for ii=1 :ii < d_whc
              d_v(ii) = 0.0;
           end
                case 4
                      d_c = 1;   d_w = arg.w; d_h = arg.h; d_wh = arg.w*arg.h;  d_whc = arg.w*arg.h;  d_v = zeros(1,arg.w*arg.h);  visuMin = 0.0; visuMax = 255.0; 
         
            case 5
                 d_c = 3;   d_w = arg.w; d_h = arg.h; d_wh = arg.w*arg.h;  d_whc = 3*arg.w*arg.h;  d_v = zeros(1,3*arg.w*arg.h);  visuMin = 0.0; visuMax = 255.0;  
      
                case 6  
                     d_c = 0;   d_w = 0; d_h = 0; d_wh = 0;  d_whc = 0;  d_v = 0;  visuMin = 0.0; visuMax = 255.0;  
      
          if((arg.red.d_w == arg.green.d_w) &&(arg.green.d_w == arg.blue.d_w))
              disp('Assertion error');
          end
           if((arg.red.d_h == arg.green.d_h) &&(arg.green.d_h == arg.blue.d_h))
              disp('Assertion error');
           end
          d_w = arg.red.d_w;
          d_h = arg.red.d_h;
          d_c = 3;
          d_wh = d_w * d_h;
          d_whc = d_wh * d_c;
          d_v = zeros(1,3*d_wh);
                case 1
                      d_c = arg.im.d_c;   d_w =  arg.im.d_w; d_h =  arg.im.d_h; d_wh =  arg.im.d_wh;  d_whc =  arg.im.d_whc;  d_v = 0;  visuMin = 0.0; visuMax = 255.0;
                      if(d_whc > 0)
                         disp('do nothing lol'); 
                      end
          
        end
        end
            
        function d_v= create(obj,arg)
           d_c = arg.c;
           d_w = arg.w;
           d_h = arg.h;
           d_wh = arg.w*arg.h;
           d_whc = arg.c*arg.w*arg.h;
           d_v = zeros(1,d_whc);
           visuMax = 255.0;
           visuMin = 0.0;
        end
        end
       
   
end

