%
% Name:         demo_ICA.m
%               
% Description:  Demonstrates the performance of ICA by decomposing
%               correlated multivariate Gaussian samples into
%               uncorrelated and maximally independent data streams
%               
%               When d == r, the ICA reconstruction is *exact*. Thus
%               ICA effectively transforms the input data into
%               uncorrelated, independent components while preserving
%               information
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         April 26, 2015
%

rng(1);

% Knobs
n = 100;    % # samples
d = 3;      % Sample dimension
r = 2;      % # independent components

% Generate Gaussian data
MU = 10 * rand(d,1);
sigma = (2 * randi([0 1],d) - 1) .* rand(d);
SIGMA = 3 * (sigma * sigma');
Z = myMultiGaussian(MU,SIGMA,n);

% Perform ICA
[Zica A T mu] = myICA(Z,r);
Zr = T \ pinv(A) * Zica + repmat(mu,1,n);

% Plot indpendent components
figure;
for i = 1:r
    subplot(r,1,i);
    plot(Zica(i,:),'b');
    grid on;
    ylabel(sprintf('Zica(%i,:)',i));
end
subplot(r,1,1);
title('Independent Components');

% Plot r-dimensional approximations
figure;
for i = 1:d
    subplot(d,1,i);
    hold on;
    p1 = plot(Z(i,:),'--r');
    p2 = plot(Zr(i,:),'-.b');
    grid on;
    ylabel(sprintf('Z(%i,:)',i));
end
subplot(d,1,1);
title(sprintf('%iD ICA approximation of %iD data',r,d));
legend([p1 p2],'Z','Zr');
