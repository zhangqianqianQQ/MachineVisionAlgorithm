function [sPb, sPb_thin] = spectralPb_RGBD(mPb2, nvec, dthresh, ic_gamma, mult, mult2)
% function [sPb] = spectralPb(mPb, orig_sz, outFile, nvec)
%
% description:
%   global contour cue from local mPb.
%
% computes Intervening Contour with BSE code by Charless Fowlkes:
%
%http://www.cs.berkeley.edu/~fowlkes/BSE/
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
% December 2010
if nargin<6, mult2 = 125; end
if nargin<5, mult = 3; end
if nargin<4, ic_gamma = 0.15; end
if nargin<3, dthresh = 2; end
if nargin<2, nvec = 25; end

[tx2, ty2] = size(mPb2);
tx=(tx2-1)/2; ty=(ty2-1)/2;

l{1} = mult*mPb2(1:2:end,2:2:end);
l{2}= mult*mPb2(2:2:end,1:2:end);

% build the pairwise affinity matrix
[val,I,J] = buildW(l{1},l{2}, dthresh, ic_gamma);
W = sparse(val,I,J);

[wx, wy] = size(W);
x = 1 : wx;
S = full(sum(W, 1));
D = sparse(x, x, S, wx, wy);
clear S x;

opts.issym=1;
opts.isreal = 1;
opts.disp=0;
[EigVect, EVal] = eigs(D - W, D, nvec, 'sm', opts);
clear D W opts;

EigVal = diag(EVal);
clear Eval;

EigVal(1:end) = EigVal(end:-1:1);
EigVect(:, 1:end) = EigVect(:, end:-1:1);

vect = zeros(tx, ty, nvec);
for v = 2 : nvec,
    vect(:, :, v) = reshape(EigVect(:, v), [ty tx])';
end
clear EigVect;

%% spectral Pb
for v=2:nvec,
    vect(:,:,v)=(vect(:,:,v)-min(min(vect(:,:,v))))/(max(max(vect(:,:,v)))-min(min(vect(:,:,v))));
end

% OE parameters
hil = 0;
deriv = 1;
support = 3;
sigma = 1;
norient = 8;
dtheta = pi/norient;
ch_per = [4 3 2 1 8 7 6 5];

sPb = zeros(tx, ty, norient);
sPb_thin = zeros(tx, ty);
for v = 1 : nvec
    if EigVal(v) > 0,
        vec = vect(:,:,v)/sqrt(EigVal(v));
        sPb_thin = sPb_thin + seg2bdry_wt(vec, 'imageSize');
        for o = 1 : norient,
            theta = dtheta*o;
            f = oeFilter(sigma, support, theta, deriv, hil);
            sPb(:,:,ch_per(o)) = sPb(:,:,ch_per(o)) + abs(applyFilter(f, vec));
        end
    end
end

%scale raw output
sPb = sPb/mult2;
sPb_thin = sPb_thin/mult2;


%%
function [ bdry ]  = seg2bdry_wt(seg, fmt)
if nargin<2, fmt = 'doubleSize'; end;

if ~strcmp(fmt,'imageSize') && ~strcmp(fmt,'doubleSize'),
    error('possible values for fmt are: imageSize and doubleSize');
end

[tx, ty, nch] = size(seg);

if nch ~=1, 
    error('seg must be a scalar image');
end

bdry = zeros(2*tx+1, 2*ty+1);

edgels_v = abs( seg(1:end-1, :) - seg(2:end, :) );
edgels_v(end+1, :) = 0;
edgels_h = abs( seg(:, 1:end-1) - seg(:, 2:end) );
edgels_h(:, end+1) = 0;

bdry(3:2:end, 2:2:end) = edgels_v;
bdry(2:2:end, 3:2:end) = edgels_h;
bdry(3:2:end-1, 3:2:end-1)= max ( max(edgels_h(1:end-1, 1:end-1), edgels_h(2:end, 1:end-1)), max(edgels_v(1:end-1,1:end-1), edgels_v(1:end-1,2:end)) );

bdry(1, :) = bdry(2, :);
bdry(:, 1) = bdry(:, 2);
bdry(end, :) = bdry(end-1, :);
bdry(:, end) = bdry(:, end-1);

if strcmp(fmt,'imageSize'),
    bdry = bdry(3:2:end, 3:2:end);
end
