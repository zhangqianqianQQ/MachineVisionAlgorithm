function [alpha,bias] = smo(K, y, C, tol)

% SMO: SMO algorithm for SVM
%
%Implementation of the Sequential Minimal Optimization (SMO)
%training algorithm for Vapnik's Support Vector Machine (SVM)
%
% This is a modified code from Gavin Cawley's MATLAB Support 
% Vector Machine Toolbox
% (c) September 2000.
% 
% Diego Andres Alvarez.
%
% USAGE: [alpha,bias] = smo(K, y, C, tol)
%
% INPUT:
%
%   K: n x n kernel matrix
%   y: 1 x n vector of labels, -1 or 1
%   C: a regularization parameter such that 0 <= alpha_i <= C/n
%   tol: tolerance for terminating criterion
%
% OUTPUT:
%
%   alpha: 1 x n lagrange multiplier coefficient
%   bias: scalar bias (offset) term

% Input/output arguments modified by JooSeuk Kim and Clayton Scott, 2007

global SMO;

[ntp,ntp] = size(K);
%recompute C
C = C/ntp;

%initialize
ii0 = find(y == -1);
ii1 = find(y == 1);

i0 = ii0(1);
i1 = ii1(1);

alpha_init = zeros(ntp, 1);
alpha_init(i0) = C;
alpha_init(i1) = C;
bias_init = C*(K(i0,i1) - K(i0,i0)) + 1;

%Inicializando las variables
SMO.epsilon = 10^(-6); SMO.tolerance = tol;
SMO.y = y'; SMO.C = C;
SMO.alpha = alpha_init; SMO.bias = bias_init;
SMO.ntp = ntp; %number of training points

%CACHES:
SMO.Kcache = K; %kernel evaluations
SMO.error = zeros(SMO.ntp,1); %error 

numChanged = 0; examineAll = 1;

%When all data were examined and no changes done the loop reachs its 
%end. Otherwise, loops with all data and likely support vector are 
%alternated until all support vector be found.
while ((numChanged > 0) | examineAll)
    numChanged = 0;
    if examineAll
        %Loop sobre todos los puntos
        for i = 1:ntp
            numChanged = numChanged + examineExample(i);
        end; 
    else
        %Loop sobre KKT points
        for i = 1:ntp
            %Solo los puntos que violan las condiciones KKT
            if (SMO.alpha(i)>SMO.epsilon) & (SMO.alpha(i)<(SMO.C-SMO.epsilon))
                numChanged = numChanged + examineExample(i);
            end;
        end;
    end;
    
    if (examineAll == 1)
        examineAll = 0;
    elseif (numChanged == 0)
        examineAll = 1;
    end;
end;
alpha = SMO.alpha';
alpha(find(alpha < SMO.epsilon)) = 0;
alpha(find(alpha > C-SMO.epsilon)) = C;
bias = -SMO.bias;
return;

function RESULT = fwd(n)
global SMO;
LN = length(n);
RESULT = -SMO.bias + sum(repmat(SMO.y,1,LN) .* repmat(SMO.alpha,1,LN) .* SMO.Kcache(:,n))';
return;

function RESULT = examineExample(i2)
%First heuristic selects i2 and asks to examineExample to find a
%second point (i1) in order to do an optimization step with two 
%Lagrange multipliers

global SMO;
alpha2 = SMO.alpha(i2); y2 = SMO.y(i2);

if ((alpha2 > SMO.epsilon) & (alpha2 < (SMO.C-SMO.epsilon)))
    e2 = SMO.error(i2);
else
    e2 = fwd(i2) - y2;
end;

% r2 < 0 if point i2 is placed between margin (-1)-(+1)
% Otherwise r2 is > 0. r2 = f2*y2-1

r2 = e2*y2; 
%KKT conditions:
% r2>0 and alpha2==0 (well classified)
% r2==0 and 0% r2<0 and alpha2==C (support vectors between margins)
%
% Test the KKT conditions for the current i2 point. 
%
% If a point is well classified its alpha must be 0 or if
% it is out of its margin its alpha must be C. If it is at margin
% its alpha must be between 0%take action only if i2 violates Karush-Kuhn-Tucker conditions
if ((r2 < -SMO.tolerance) & (alpha2 < (SMO.C-SMO.epsilon))) | ...
((r2 > SMO.tolerance) & (alpha2 > SMO.epsilon))
    % If it doens't violate KKT conditions then exit, otherwise continue.

    %Try i2 by three ways; if successful, then immediately return 1; 
    RESULT = 1;
    % First the routine tries to find an i1 lagrange multiplier that
    % maximizes the measure |E1-E2|. As large this value is as bigger 
    % the dual objective function becames.
    % In this first test, only support vectors will be tested.

    POS = find((SMO.alpha > SMO.epsilon) & (SMO.alpha < (SMO.C-SMO.epsilon)));
    [MAX,i1] = max(abs(e2 - SMO.error(POS)));
    if ~isempty(i1)
        if takeStep(i1, i2, e2), return;
        end;
    end;

    %The second heuristic choose any Lagrange Multiplier that is a SV and tries to optimize
    for i1 = randperm(SMO.ntp)
        if (SMO.alpha(i1) > SMO.epsilon) & (SMO.alpha(i1) < (SMO.C-SMO.epsilon))
        %if a good i1 is found, optimise
            if takeStep(i1, i2, e2), return;
            end;
        end
    end

    %if both heuristc above fail, iterate over all data set 
    for i1 = randperm(SMO.ntp)
        if ~((SMO.alpha(i1) > SMO.epsilon) & (SMO.alpha(i1) < (SMO.C-SMO.epsilon)))
            if takeStep(i1, i2, e2), return;
            end;
        end
    end;
end; 

%no progress possible
RESULT = 0;
return;


function RESULT = takeStep(i1, i2, e2)
% for a pair of alpha indexes, verify if it is possible to execute
% the optimisation described by Platt.

global SMO;
RESULT = 0;
if (i1 == i2), return; 
end;

% compute upper and lower constraints, L and H, on multiplier a2
alpha1 = SMO.alpha(i1); alpha2 = SMO.alpha(i2);
y1 = SMO.y(i1); y2 = SMO.y(i2);
C = SMO.C; K = SMO.Kcache;

s = y1*y2;
if (y1 ~= y2)
    L = max(0, alpha2-alpha1); H = min(C, alpha2-alpha1+C);
else
    L = max(0, alpha1+alpha2-C); H = min(C, alpha1+alpha2);
end;

if (L == H), return;
end;

if (alpha1 > SMO.epsilon) & (alpha1 < (C-SMO.epsilon))
    e1 = SMO.error(i1);
else
    e1 = fwd(i1) - y1;
end;

%if (alpha2 > SMO.epsilon) & (alpha2 < (C-SMO.epsilon))
% e2 = SMO.error(i2);
%else
% e2 = fwd(i2) - y2;
%end;

%compute eta
k11 = K(i1,i1); k12 = K(i1,i2); k22 = K(i2,i2);
eta = 2.0*k12-k11-k22;

%recompute Lagrange multiplier for pattern i2
if (eta < 0.0)
    a2 = alpha2 - y2*(e1 - e2)/eta;

    %constrain a2 to lie between L and H
    if (a2 < L)
        a2 = L;
    elseif (a2 > H)
        a2 = H;
    end;
else
%When eta is not negative, the objective function W should be
%evaluated at each end of the line segment. Only those terms in the
%objective function that depend on alpha2 need be evaluated... 

    ind = find(SMO.alpha>0);

    aa2 = L; aa1 = alpha1 + s*(alpha2-aa2);

    Lobj = aa1 + aa2 + sum((-y1*aa1/2).*SMO.y(ind).*K(ind,i1) + (-y2*aa2/2).*SMO.y(ind).*K(ind,i2));

    aa2 = H; aa1 = alpha1 + s*(alpha2-aa2);
    Hobj = aa1 + aa2 + sum((-y1*aa1/2).*SMO.y(ind).*K(ind,i1) + (-y2*aa2/2).*SMO.y(ind).*K(ind,i2));

    if (Lobj>Hobj+SMO.epsilon)
        a2 = H;
    elseif (Lobj<Hobj-SMO.epsilon)
        a2 = L;
    else
        a2 = alpha2;
    end;
end;

if (abs(a2-alpha2) < SMO.epsilon*(a2+alpha2+SMO.epsilon))
    return;
end;

% recompute Lagrange multiplier for pattern i1
a1 = alpha1 + s*(alpha2-a2);

w1 = y1*(a1 - alpha1); w2 = y2*(a2 - alpha2);

%update threshold to reflect change in Lagrange multipliers
b1 = SMO.bias + e1 + w1*k11 + w2*k12; 
bold = SMO.bias;

if (a1>SMO.epsilon) & (a1<(C-SMO.epsilon))
    SMO.bias = b1;
else
    b2 = SMO.bias + e2 + w1*k12 + w2*k22;
    if (a2>SMO.epsilon) & (a2<(C-SMO.epsilon))
        SMO.bias = b2;
    else
        SMO.bias = (b1 + b2)/2;
    end;
end;

% update error cache using new Lagrange multipliers
SMO.error = SMO.error + w1*K(:,i1) + w2*K(:,i2) + bold - SMO.bias;
SMO.error(i1) = 0.0; SMO.error(i2) = 0.0;

% update vector of Lagrange multipliers
SMO.alpha(i1) = a1; SMO.alpha(i2) = a2;

%report progress made
RESULT = 1;
return;
