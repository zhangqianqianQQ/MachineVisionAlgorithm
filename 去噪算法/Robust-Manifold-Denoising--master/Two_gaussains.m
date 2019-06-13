function [X]=Two_gaussains(n)

rng default; % For reproducibility
X = [randn(n,2)*0.75+ones(n,2);
    randn(n,2)*0.5-ones(n,2)];

figure;
plot(X(:,1),X(:,2),'.');
title 'Randomly Generated Data';

X=X';
