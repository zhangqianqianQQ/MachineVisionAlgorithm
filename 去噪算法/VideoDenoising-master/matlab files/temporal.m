function output = temporal(curr,prev,alpha,T)
curr=double(curr);
prev=double(prev);
diff = curr-prev;
m = sign(abs(diff)).*(abs(diff)<T);
av = alpha.*curr+(1-alpha).*prev;
output = curr;
m=m&m;
output(m)=av(m);
output=uint8(output);
end