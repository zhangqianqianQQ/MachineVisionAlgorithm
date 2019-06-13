function [nuOut sigmaOut]=ricePairInversion(mu,s)
% Computes (nu,sigma) pair from (mu,s) pair, where mu=E{z|nu,sigma} and s=std{z|nu,sigma}
% for Rician-distributed z ~ R(nu,sigma)
% --------------------------------------------------------------------------------------------
%
% SYNTAX
% ------
% [ nuOut sigmaOut ] = ricePairInversion ( mu , s )
%
%
% OUTPUT
% ------
% nuOut        :  computed value of nu
% sigmaOut     :  computed value of sigma
%
%
% INPUTS
% ------
% mu          :  Rician-distributed data, following the model
% s           :  standard-deviation parameter (see above)
%
%
%
% --------------------------------------------------------------------------------------------
%
%
% author:                Alessandro Foi
%
% web page:              http://www.cs.tut.fi/~foi/RiceOptVST
%
% contact:               firstname.lastname@tut.fi
%
% --------------------------------------------------------------------------------------------
% Copyright (c) 2010-2012 Tampere University of Technology.
% All rights reserved.
% This work should be used for nonprofit purposes only.
% --------------------------------------------------------------------------------------------
%
% Disclaimer
% ----------
%
% Any unauthorized use of these routines for industrial or profit-oriented activities is
% expressively prohibited. By downloading and/or using any of these files, you implicitly
% agree to all the terms of the TUT limited license (included in the file Legal_Notice.txt).
% --------------------------------------------------------------------------------------------
%

load('Rice_VST_A.mat','nu','Ez','stdz')

nu_over_sigma=interp1(Ez./stdz,nu,mu./s,'linear','extrap');  % this the inverse of H

W=mu./s>(Ez(end)./stdz(end));   % asymptotic
nu_over_sigma(W)=mu(W)./s(W)-0.75*s(W)./mu(W);

W=mu./s<Ez(1)/stdz(1);   % trivial regularization
nu_over_sigma(W)=Ez(1)/stdz(1);

sigmaOut=sqrt((s^2+mu^2)/(2+nu_over_sigma^2));
nuOut=sqrt(s^2+mu^2-2*sigmaOut^2);

W=s<=0;   % needed if s and mu are both zero
sigmaOut(W)=0;
nuOut(W)=max(0,mu(W));
