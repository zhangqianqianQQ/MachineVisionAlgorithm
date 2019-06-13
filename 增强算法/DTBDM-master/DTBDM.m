close all;
x=imread('G:\project\imgpro2\Lena.bmp');
x =imresize(x,[512 512]);
NOISE_VAR = 0.2;
y=x;
%for z = 1:75
 r = randi(255,1,2);
 y=pepperOrSalt(y,NOISE_VAR, 3, r(1), r(2));
%end
y = double(y);
decision1=0;decision2=0;decision3=0;decision4=0;
f = y;f_m = y;
[R, C] = size(x);
th_ima=20;th_imb=25;th_fma=40;th_fmb=80;th_sma=15;th_smb=60;
for z =1:1
for i = 2:R-1
    for j = 2:C-1

        tmp =y(i-1:i+1,j-1:j+1);
        w_top_half=[y(i-1,j-1),y(i-1,j),y(i-1,j+1),y(i,j-1)];
        w_bottom_half=[y(i,j+1),y(i+1,j-1),y(i+1,j),y(i+1,j+1)];
        s_top = sort(w_top_half);
        s_bottom = sort(w_bottom_half);
        s_top_max = s_top(4);
        s_top_min = s_top(1);
        s_bottom_min = s_bottom(1);
        s_bottom_max = s_bottom(4);
        top_half_diff = abs(s_top_max-s_top_min);
        bottom_half_diff = abs(s_bottom_max-s_bottom_min);
        if (top_half_diff>=th_ima || bottom_half_diff>=th_ima)
            decision1=1;
        else
            decision1=0;
        end
        if(decision1==0)
         if(abs(y(i,j)-s_top_max)>=th_imb || abs(y(i,j)-s_top_min)>=th_imb)
            im_top_half=1;
         else
            im_top_half=0;
         end
         if(abs(y(i,j)-s_bottom_max)>=th_imb || abs(y(i,j)-s_bottom_min)>=th_imb)
            im_bottom_half=1;
         else
            im_bottom_half=0;
         end
         if(im_top_half==1 || im_bottom_half==1)
           decision2 =1;
         else
           decision2 =0;
         end
        %else
         %   y(i,j) = y(i,j);
        end
        %if(decision2==1)
            if(abs(y(i-1,j-1)-y(i,j))>=th_fma || abs(y(i+1,j+1)-y(i,j))>=th_fma || abs(y(i-1,j-1)-y(i+1,j+1))>=th_fma)
                fm_e1=0;%no edge
            else
                fm_e1=1;
            end
            if(abs(y(i-1,j+1)-y(i,j))>=th_fma || abs(y(i+1,j-1)-y(i,j))>=th_fma || abs(y(i-1,j+1)-y(i+1,j-1))>=th_fma)
                fm_e2=0;
            else
                fm_e2=1;
            end
            if(abs(y(i-1,j)-y(i,j))>=th_fma || abs(y(i+1,j)-y(i,j))>=th_fma || abs(y(i-1,j)-y(i+1,j))>=th_fma)
                fm_e3=0;
            else
                fm_e3=1;
            end
            if(abs(y(i,j-1)-y(i,j))>=th_fma || abs(y(i,j+1)-y(i,j))>=th_fma || abs(y(i,j-1)-y(i,j+1))>=th_fma)
                fm_e4=0;
            else
                fm_e4=1;
            end
            if(fm_e1==1 || fm_e2==1 || fm_e3==1 || fm_e4==1)
                decision3=0;
            else
                decision3=1;
            end
        %else
         %   y(i,j) = y(i,j);
        %end
        %if(decision3==1)
            s_w=sort(tmp);
            w4=s_w(4);
            w_median=s_w(5);
            w6=s_w(6);
            w_max=w6+th_sma;
            w_min=w4-th_sma;
            if(w_max<=w_median+th_smb)
                n_max=w_max;
            else
                n_max=w_median+th_smb;
            end
            if(w_min>=w_median-th_smb)
                n_min=w_min;
            else
                n_min=w_median-th_smb;
            end
            if(y(i,j)>=n_max || y(i,j)<=n_min)
                decision4=1;
            else
                decision4=0;
            end
        %else
         %   y(i,j) = y(i,j);
        %end
        if(((decision4==1)||(decision3==1)||((decision2==1)&&(decision1==0))))
            d1=abs(y(i,j-1)-y(i+1,j+1))+abs(y(i-1,j-1)-y(i,j+1));
            d2=abs(y(i-1,j-1)-y(i+1,j))+abs(y(i-1,j)-y(i+1,j+1));
            d3=(abs(y(i-1,j)-y(i+1,j)))*2;
            d4=abs(y(i-1,j)-y(i+1,j-1))+abs(y(i-1,j+1)-y(i+1,j));
            d5=abs(y(i-1,j+1)-y(i,j-1))+abs(y(i,j+1)-y(i+1,j-1));
            d6=(abs(y(i,j-1)-y(i,j+1)))*2;
            d7=(abs(y(i-1,j-1)-y(i+1,j+1)))*2;
            d8=(abs(y(i-1,j+1)-y(i+1,j-1)))*2;
            if((y(i,j-1)>=w_max || y(i,j-1)<=w_min) && (y(i,j+1)>=w_max ||y(i,j+1)<=w_min) && (y(i+1,j-1)>=w_max || y(i+1,j-1)<=w_min )&& (y(i+1,j)>=w_max || y(i+1,j)<=w_min) && (y(i+1,j+1)>=w_max || y(i+1,j+1)<=w_min))
                f(i,j)=(y(i-1,j-1)+(y(i-1,j)*2)+y(i-1,j+1))/4;
            else
                if(y(i,j-1)>=w_max || y(i,j-1)<=w_min)
                d_m=[d2 d3 d4 d7 d8];
                elseif(y(i,j+1)>=w_max ||y(i,j+1)<=w_min)
                d_m=[d2 d3 d4 d7 d8];
                elseif(y(i+1,j-1)>=w_max || y(i+1,j-1)<=w_min)
                d_m=[d1 d2 d3 d6 d7];
                elseif(y(i+1,j)>=w_max || y(i+1,j)<=w_min)
                d_m=[d1 d5 d6 d7 d8];
                elseif(y(i+1,j+1)>=w_max || y(i+1,j+1)<=w_min)
                d_m=[d3 d4 d5 d6 d8];
                else    
                d_m=[d1 d2 d3 d4 d5 d6 d7 d8];
                end
             s_d=sort(d_m);
             d_min=s_d(1);
             if(d_min==d1)
                y(i,j)=(y(i-1,j-1)+y(i,j-1)+y(i,j+1)+y(i+1,j+1))/4;
             elseif(d_min==d2)
                y(i,j)=(y(i-1,j-1)+y(i-1,j)+y(i+1,j)+y(i+1,j+1))/4;
             elseif(d_min==d3)
                y(i,j)=(y(i-1,j)+y(i+1,j))/2;
             elseif(d_min==d4)
                y(i,j)=(y(i-1,j)+y(i-1,j+1)+y(i+1,j-1)+y(i+1,j))/4;
             elseif(d_min==d5)
                y(i,j)=(y(i-1,j+1)+y(i,j-1)+y(i,j+1)+y(i+1,j-1))/4;
             elseif(d_min==d6)
                y(i,j)=(y(i,j-1)+y(i,j+1))/2;
             elseif(d_min==d7)
                y(i,j)=(y(i-1,j-1)+y(i+1,j+1))/2;
             elseif(d_min==d8)
                y(i,j)=(y(i-1,j+1)+y(i+1,j-1))/2;
             end
            end
         m=[y(i,j) y(i-1,j) y(i,j-1) y(i,j+1) y(i+1,j)];
         y(i,j) = median(m);
        %else
         %   y(i,j) = y(i,j);
        end
        %if(f_m(i,j)>=n_max||f_m(i,j)<=n_min)
         %   if((f_m(i-1,j-1)<n_max)&&(f_m(i-1,j-1)>n_min))
          %      f_m(i,j)=f_m(i-1,j-1);
           % elseif((f_m(i-1,j)<n_max)&&(f_m(i-1,j)>n_min))
            %    f_m(i,j)=f_m(i-1,j);
            %elseif((f_m(i-1,j+1)<n_max)&&(f_m(i-1,j+1)>n_min))
             %   f_m(i,j)=f_m(i-1,j+1);
            %elseif((f_m(i,j-1)<n_max)&&(f_m(i,j-1)>n_min))
            %    f_m(i,j)=f_m(i,j-1);
            %elseif((f_m(i,j+1)<n_max)&&(f_m(i,j+1)>n_min))
             %   f_m(i,j)=f_m(i,j+1);
            %elseif((f_m(i+1,j-1)<n_max)&&(f_m(i+1,j-1)>n_min))
             %   f_m(i,j)=f_m(i+1,j-1);
            %elseif((f_m(i+1,j)<n_max)&&(f_m(i+1,j)>n_min))
             %   f_m(i,j)=f_m(i+1,j);
            %elseif((f_m(i+1,j+1)<n_max)&&(f_m(i+1,j+1)>n_min))
             %   f_m(i,j)=f_m(i+1,j+1);
            %else
             %   f_m(i,j)=(f_m(i-1,j-1)+(f_m(i-1,j)*2)+f_m(i-1,j+1))/4;
            %end
        %end
    end
end
end
figure(1);imshow(x);figure(2);imshow(f_m,[]);figure(3);imshow(y,[]);
squaredErrorImage = (double(x) - (y)) .^ 2;
mse = sum(sum(squaredErrorImage)) / (R * C);
PSNR = 10 * log10( 255^2 / mse);
r1=rand_index(y);
v=uint8(y);
u=uint8(f_m);
gce1 = global_consistancy_error(y);
jaccardIndex_ac = sum(x(:) & v(:)) / sum(x(:) | v(:));
message = sprintf('The mean square error for denoised image is %.2f.\nThe PSNR = %.2f.\nThe Rand_index = %.2f.\nThe global_consistancy_error = %.2f.\nThe jaccard coefficient = %.2f.\nThe jaccard distance = %.2f.', mse, PSNR, r1,gce1,jaccardIndex_ac,1-jaccardIndex_ac);
msgbox(message);
imwrite(v,'G:\project\imgpro2\img.bmp');
squaredErrorImage1 = (double(x) - (f_m)) .^ 2;
mse1 = sum(sum(squaredErrorImage1)) / (R * C);
PSNR1 = 10 * log10( 255^2 / mse1);
r2=rand_index(f_m);
gce2 = global_consistancy_error(f_m);
jaccardIndex_ac2 = sum(x(:) & u(:)) / sum(x(:) | u(:));
message = sprintf('The mean square error for noisy image is %.2f.\nThe PSNR = %.2f.\nThe Rand_index = %.2f.\nThe global_consistancy_error = %.2f.\nThe jaccard coefficient = %.2f.\nThe jaccard distance = %.2f.', mse1, PSNR1, r2, gce2,jaccardIndex_ac2,1-jaccardIndex_ac2);
msgbox(message);
x1=logical(x);
y1=logical(y);
n=jaccard_coefficient(x1,y1);



