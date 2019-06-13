%demostration of ridge regression

load('valData.mat');

% using mean of each bag as represetation
trD = cellfun( @(x)sum(x,2),trD,'UniformOutput', false) ;
trD=ML_Norm.l2norm( cat(2,trD{:}));

tstD = cellfun( @(x)sum(x,2),tstD,'UniformOutput', false) ;
tstD=ML_Norm.l2norm( cat(2,tstD{:}));


lambdas = 1*[0, 10.^(-10:3)];
fprintf('As lambda increase, the error should increase\n');
 for i=1:length(lambdas)
     lambda = lambdas(i);
[w, b] = ML_Ridge.ridgeReg(trD, trLb, lambda, []);
err = trD'*w + b - trLb;
totalErr = sum(err.^2);

pred=tstD'*w+b;
ap=ml_ap(pred,tstLb,false);
fprintf('lambda: %10g,  err: %15g,ap:  %.2f\n', lambda, totalErr, ap);
 end
