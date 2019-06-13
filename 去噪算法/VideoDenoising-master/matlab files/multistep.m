function C=multistep(x,N,ld)
x=im2double(x);
[m n]=size(x);
C=x;
for k=0:1:N-1
    R=getcorner(C,m/2^k,n/2^k);
    S=wave_transform(R,ld);
    C=putcorner(C,S);
end
end
function r=getcorner(C,m,n)
    r=C(1:m,1:n);
end
function x=putcorner(c,a)
    [m n]=size(a);
    c(1:m,1:n)=a;
    x=c;
end