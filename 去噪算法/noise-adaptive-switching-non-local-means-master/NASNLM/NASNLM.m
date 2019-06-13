function output_image = NASNLM(input_image,t,f,h)
[row, column] = size(input_image);
output_image = zeros(row,column);
output_image1 = zeros(row,column);
input_image2 = padarray(input_image,[3 3],'symmetric');
L_min = 0;
L_max = 255;
F = F_(input_image2);
[G1,G2,G3] = G_(input_image2,F);

for i =4:(row+3)
	for j = 4:(column+3)
	
		if L_min<input_image2(i,j) && input_image2(i,j)<L_max
			output_image1(i-3,j-3) = input_image2(i,j);
		else 
			if G1(i,j)>0
				d1 = abs(input_image2(i-1,j-1)-input_image2(i+1,j+1));
				d2 = abs(input_image2(i-1,j)-input_image2(i+1,j));
				d3 = abs(input_image2(i-1,j+1)-input_image2(i+1,j-1));
				d4 = abs(input_image2(i,j-1)-input_image2(i,j+1));
				if F(i-1,j-1)==0 || F(i+1,j+1)==0
					d1 = 512;
				end
				if F(i-1,j)==0 || F(i+1,j)==0
					d2 = 512;	
				end
				if F(i-1,j+1)==0 || F(i+1,j-1)==0
					d3 = 512;	
				end
				if F(i,j-1)==0 || F(i,j+1)==0
					d4 = 512;
				end
				d= [d1,d2,d3,d4];
				d_min = min(d);
				
				if d_min==512
					count=0;
                    x=zeros(1,9);
					for m=-1:1
						for n=-1:1
							if F(i+m,j+n)==1
								count=count+1;
								x(1,count) =input_image2(i+m,j+n);
							end
						end
					end
					output_image1(i-3,j-3)=median(x(:,1:count));
				else
					if d_min==d1
						output_image1(i-3,j-3)=(input_image2(i-1,j-1)+input_image2(i+1,j+1))/2;
                    elseif d_min==d2
						output_image1(i-3,j-3)=(input_image2(i-1,j)+input_image2(i+1,j))/2;
                    elseif d_min==d3
						output_image1(i-3,j-3)=(input_image2(i-1,j+1)+input_image2(i+1,j-1))/2;
                    elseif d_min==d4
						output_image1(i-3,j-3)=(input_image2(i,j-1)+input_image2(i,j+1))/2;
					end
				end
				
            elseif G2(i,j)>0
				count=0;
                x=zeros(1,25);
				for m=-2:2
					for n=-2:2
						if F(i+m,j+n)==1
							count=count+1;
							x(1,count) =input_image2(i+m,j+n);
						end
					end
				end
				output_image1(i-3,j-3)=median(x(:,1:count));
            elseif G3(i,j)>0
				count=0;
				for m=-3:3
					for n=-3:3
						if F(i+m,j+n)==1
							count=count+1;
							x(1,count) =input_image2(i+m,j+n);
						end
					end
				end
				output_image1(i-3,j-3)=median(x(:,1:count));						
			else
				output_image1(i-3,j-3)=median(median(input_image2(i-1:i+1,j-1:j+1)));							
			end
        end
	end
end

input_image3 = padarray(output_image1,[f+t f+t],'symmetric');
F = padarray(F(4:row+3,4:column+3),[f+t f+t],'symmetric');
kernel = make_kernel(f);
kernel = kernel / sum(sum(kernel));
for i =1:row
	for j=1:column
		i1 = i+ f+t;
        j1 = j+ f+t;
		if F(i1,j1)==1
			output_image(i,j)=input_image3(i1,j1);
		else
			W1= input_image3(i1-f:i1+f , j1-f:j1+f);%小窗口
			wmax=0; 
			average=0;
			sweight=0;		
			value=0;
			rmin=i1-t;
			rmax=i1+t;
			smin=j1-t;
			smax=j1+t;
			for r=rmin:1:rmax %大窗口
				for s=smin:1:smax
					if(r==i1 && s==j1) 
						continue; 
					end
					W2= input_image3(r-f:r+f , s-f:s+f);    %大搜索窗口中的小相似性窗口     
					d = sum(sum(kernel.*(W1-W2).*(W1-W2)));
					w=exp(-d/(h^2)); %权重
					if w>wmax                
						wmax=w;   %求最大权重            
					end
					sweight = sweight + w;  %大窗口中的权重和
					average = average + w*input_image3(r,s);   
				end
			end
			average = average + wmax*input_image3(i1,j1);
			sweight = sweight + wmax;
			if sweight > 0
				output_image(i,j) = average / sweight;
			else
				output_image(i,j) = output_image1(i,j);
			end
		end
	end
end
end

function F = F_(input_image2)
[r,c] = size(input_image2);
F = zeros(r,c);
L_min = 0;
L_max = 255;
for i =1:r
	for j = 1:c
		if input_image2(i,j)==L_min || input_image2(i,j)==L_max
			F(i,j) = 0;
		else
			F(i,j) = 1;
		end
	end
end
end

function [G1,G2,G3] = G_(input_image2,F)
[r,c] = size(input_image2);
G1 = zeros(r,c);
G2 = zeros(r,c);
G3 = zeros(r,c);

for i=4:(r-3)
	for j = 4:(c-3)
	
		if F(i,j)==0
			G1_count = 0;
			G2_count = 0;
			G3_count = 0;
			for m = -1:1
				for n = -1:1
					if F(i+m,j+n)==1
						G1_count = G1_count + 1;
					end
				end
			end
			G1(i,j)=G1_count;
			
			for m = -2:2
				for n = -2:2
					if F(i+m,j+n)==1
						G2_count = G2_count + 2;
					end
				end
			end
			G2(i,j)=G2_count;
			
			for m = -3:3
				for n = -3:3
					if F(i+m,j+n)==1
						G3_count = G3_count + 2;
					end
				end
			end
			G3(i,j)=G3_count;		
		end
	end
end
end

function [kernel] = make_kernel(f)  
kernel=zeros(2*f+1,2*f+1);   
for d=1:f    
  value= 1 / (2*d+1)^2 ;    
  for i=-d:d
     for j=-d:d
        kernel(f+1-i,f+1-j)= kernel(f+1-i,f+1-j) + value ;
    end
  end
end
kernel = kernel ./ f;
end