I=imread('lamborghini.png');
[row , col]=size(I);
c=row*col;
h=zeros(1,256);
z=zeros(1,256);
h1=zeros(1,129);
h2=zeros(1,256);
cdf=zeros(1,256);
p=0;
q=0;
for n=1:row
  for m=1:col
    if I(n,m) == 0
     I(n,m)=1;
    end
t=I(n,m);
if(t<129)
    h1(t)=h1(t)+1;
else
    h2(t)=h2(t)+1;
end
end
end
for n=1:row
for m=1:col
    t=I(n,m);
    h(t)=h(t)+1;
end
end
for x=1:128
    p=p+h(x);
end
for x=129:255
    q=q+h(x);
end

pdf=h/c;
cdf(1)=pdf(1);
for x=2:255
    cdf(x)=pdf(x)+cdf(x-1);
end
new=round(cdf * 255);
bk=I;
for n=1:row
    for m=1:col
        t=I(n,m);
        sp=new(t);
        bk(n,m)=sp;
        z(sp)=z(sp)+1;
    end
end
subplot(2,2,1),imshow(I),title('Image 1');
pdf1=h1/p;
cdf1=zeros(1,128);
cdf1(1)=pdf1(1);
for x=2:128
    cdf1(x)=cdf1(x-1)+pdf1(x);
end
new1=round(cdf1 * 128);
pdf2=h2/q;
cdf2=zeros(1,262);
cdf2(1)=pdf2(1);
for x=129:255
    cdf2(x)=cdf2(x-1)+pdf2(x);
end
new2=round(cdf2 * 128);
for x=1:length(new2)
    new2(x)=new2(x)+128;
end

pt=zeros(1,262);
bx=I;
sp=0;
for n=1:row
    for m=1:col
        tp=I(n,m);
        if(tp<129)
            sp=new1(tp);
            pt(sp)=pt(sp)+1;
        else
            sp=new2(tp);
            pt(sp)=pt(sp)+1;
        end
        bx(n,m)=sp;
    end
end
subplot(2,2,2),imshow(bx),title('Image after bihistogram');
subplot(2,2,3),bar(z),title('Histogram equalize');
subplot(2,2,4),bar(pt),title('BiHistogram equalize');
