function I=wave_inv_transform(x,ld)
[m n]=size(x);
% [ld hd lr hr]=wfilters('sym8');
t=0:(length(ld)-1);
hd=ld; hd(end:-1:1)=cos(pi*t).*ld;
Wn=zeros(n);
Wm=zeros(m);
z=length(ld);
% l=ld;
% l(end:-1:1)=ld;
% ld=l;
j=1;
for i=1:n/2
   
        if j+z-1>n
            a=j+z-1-n;
            Wn(i,1:a)=ld(z-a+1:end);
            Wn(i,j:end)=ld(1:z-a);
        else
             Wn(i,j:j+z-1)=ld;
        end
        j=j+2;
end
j=1;
for i=n/2+1:n
   
        if j+z-1>n
            a=j+z-1-n;
            Wn(i,1:a)=hd(z-a+1:end);
            Wn(i,j:end)=hd(1:z-a);
        else
             Wn(i,j:j+z-1)=hd;
        end
        j=j+2;
end
Wn;
j=1;
for i=1:m/2
    
         if j+z-1>m
             a=j+z-1-m;
             Wm(i,1:a)=ld(z-a+1:end);
             Wm(i,j:end)=ld(1:z-a);
         else
              Wm(i,j:j+z-1)=ld;
         end
         j=j+2;
 end
 j=1;
 for i=m/2+1:m
    
         if j+z-1>m
             a=j+z-1-m;
             Wm(i,1:a)=hd(z-a+1:end);
             Wm(i,j:end)=hd(1:z-a);
         else
              Wm(i,j:j+z-1)=hd;
         end
         j=j+2;
 end
 Wm;
x=double(x);
 c=Wm'*x;
 I=c*Wn;
end