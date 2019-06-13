function FB = make_filterbank(num_ori,filter_scales,wsz,enlong)

if nargin<4,
    enlong = 3;
end

enlong = 2*enlong;


num_scale = length(filter_scales);

M1=wsz; 
M2=M1;

ori_incr=180/num_ori;
ori_offset=ori_incr/2; 

FB=zeros(M1,M2,num_ori,num_scale);

counter = 1;

for m=1:num_scale  
   for n=1:num_ori
     
      f=doog2(filter_scales(m),enlong,ori_offset+(n-1)*ori_incr,M1);
      FB(:,:,n,m)=f;
   end
end

FB=reshape(FB,M1,M2,num_scale*num_ori);
total_num_filt=size(FB,3);

for j=1:total_num_filt,
  F = FB(:,:,j);
  a = sum(sum(abs(F)));
  FB(:,:,j) = FB(:,:,j)/a;
end

