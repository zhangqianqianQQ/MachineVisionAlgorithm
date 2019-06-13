function RMSEdb =RMSE(x, y)

x=double(x);
y=double(y);
err = x - y;
err = err(:);
RMSEdb=sqrt(sum(err.^2)/length(err(:)));