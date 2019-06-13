function [results] = ms(xloc,yloc,D,param)
%
% Y. Kaloga. Version: 20-05-2019.
%
% Y. Kaloga, M. Foare, N. Pustelnik, and P. Jensen , Discrete Mumford-Shah 
% on graph for mixing matrix estimation, accepted in IEEE Signal Processing 
% Letters, 2019.

beta = param.beta;
lambda = param.lambda;
epsilon = param.epsilon;
iteration_max = param.iter_max;

%% Useful function
proj_simplex_array = @(y) max(bsxfun(@minus,y,max(bsxfun(@rdivide,cumsum(sort(y,1,'descend'),1)-1,(1:size(y,1))'),[],1)),0);
e           = 0.000001;  % petit
mat_sum     = @(M)     ( sum(M(:)) );
L1quad      = @(x)     ( mat_sum(max(abs(x(:)),x(:).*x(:)./(4*e))) );   
prox_L1quad = @(x,tau) ( max(0,min(abs(x)-tau,max(4*e,abs(x)./(tau/(2*e)+1)))).*sign(x) );
%% Useful Stuff
n1 = size(xloc,1);
n2 = size(yloc,1);
nloc = size(xloc,2);
degree = size(D,1)/(n2*nloc);
temp = xloc';
xxxloc= temp(repmat(1:nloc,n2,1),:);
clear temp
YtX = zeros(n2*nloc,n1);
for k=1:nloc
   YtX((k-1)*n2+1:k*n2,:) = yloc(:,k)*(xloc(:,k))';
end
tr = repmat(1:nloc*degree,n2,1);
oneRowYloc =yloc(:);
tD = D';
%% Initilisation
Minit = 0.5*ones(n2*nloc,n1);
for k=1:nloc
      Minit((k-1)*n2+1:k*n2,:) = proj_simplex_array(0*rand(n2,n1));
end
Finit = binornd(1,1/2,[nloc*degree,1]);
Mold = Minit;
Mnew = Minit;
Fold = Finit;
Fnew = Finit;
%% 
alpha = 1;
gamma1 = reshape(repmat((1+0.99)./(2*alpha*sum(xloc.^2,1)),n2,1),nloc*n2,1);
gamma2 = (1+0.99)/(2*beta*norm(tD*D,'fro')^2);
gamma = min(gamma1,gamma2);
delta = 1;%*mean(gamma);
ecart = inf*ones(1,iteration_max);
objectiveFunction = zeros(1,iteration_max);
time = zeros(1,iteration_max);
keepIndice = zeros(1,iteration_max);
f = @(M,F)  lambda*L1quad(F) + beta*norm((1-F(tr,:)).*(D*M),'fro')^2 +alpha*norm(oneRowYloc-sum(M.*xxxloc,2))^2;
tic
for iteration =1:iteration_max
    Fold = Fnew;
    Mold = Mnew;
    %% Mise ? jour de M
    A = -2*alpha*(YtX - sum(Mold.*xxxloc,2).*xxxloc);
    tampon1 = 2*beta*tD*(((1-Fold(tr,:)).^2).*(D*Mold));
    Mnew = Mold - gamma.*(tampon1 + A);
    Mnew = reshape(proj_simplex_array(reshape(Mnew,n2,n1*nloc)),size(Mnew,1),size(Mnew,2));
    %%  Mise ? jour de F
    d = sum(reshape((D*Mnew)',n2*n1,degree*nloc).^2,1)';
    Fnew = prox_L1quad((beta*d+Fold/(2*delta))./(beta*d+1/(2*delta)),lambda./(2*beta*d+1/delta));
    %%  R?cup?ration des informations de convergence
    if mod(iteration,iteration_max/iteration)  == 0 || iteration == 1
         keepIndice(iteration) = iteration;
        time(iteration) = toc;
        objectiveFunction(iteration) = f(Mnew,Fnew);
        ecart(iteration) = norm(Mnew-Mold,'fro');
        tic
    end
    %% Test sur la convergece
    if(ecart(iteration)< epsilon || iteration==iteration_max )%|| ecartobj(iteration) <200)
        disp("End after"+iteration+" iteration");
        keepIndice = keepIndice(keepIndice > 0);
        Mloc = zeros(n2,n1,nloc);
        for g = 1:nloc
            Mloc(:,:,g) = Mnew((g-1)*n2+1:g*n2,:);
        end
        ecart = ecart(1,keepIndice);
        objectiveFunction = objectiveFunction(1,keepIndice);
        time = time(1,keepIndice);
        break
    end
end
results.time = time;
results.ecart = ecart;
results.objectiveFunction = objectiveFunction;
results.ecart = ecart;
results.Mloc = Mloc;
results.Frontier = Fnew;