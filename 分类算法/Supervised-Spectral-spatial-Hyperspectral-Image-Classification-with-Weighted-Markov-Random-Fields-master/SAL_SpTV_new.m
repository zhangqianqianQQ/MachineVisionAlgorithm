function [U,res] = SAL_SpTV_new(Y,Training_Info,varargin)
%% [U,res] = SAL_SpTV(Y,Training_Info,varargin)

%% --------------- Description ---------------------------------------------
%
%  SAL_SpTV solves the following l_2  + TV optimization problem:
%
%     Definitions
%
%      Y  -> m * N; collection of N fractional vectors; each column  of X
%                   contains the classification probablilty
%      here Y is the probability matrix P_smlr in our paper
%      Optimization problem
%
%    min  (1/2) ||X-Y||^2_F+ lambda_tv ||HX||_{1,1};
%     X
%     X is the marginal probability q in equation (7) ,see paper
%
%    where
%
%        (1/2) ||X-Y||^2_F is a quadratic data misfit term
%
%        ||LX||_{1,1} is the TV (non-isotropic or isotropic regularizer)
%
%
%         H is a linear operator that computes the horizontal and the
%         vertical differences on each  band of X.  Let Hh: R^{n*N}-> R^{n*N}
%         be a linear operator that computes the horizontal first order
%         differences per band. HhX  computes a matrix of the same size of X
%         (we are assuming cyclic boundary), where [HhX](i,j) = X(i,h(j))-X(i,j),
%         where h(j) is the index of pixel on the right hand side of j.
%
%         For the vertical differnces, we have a similar action of Hv:
%         [HvX](i,j) = X(v(i),j)-X(i,j), where  v(i) is the index of pixel
%         on the top hand side of j.
%
%         We consider tow types of Total variation:
%
%         a)  Non-isotropic:  ||HX||_{1,1} := ||[Hh; Hv]X||_{1,1}
%
%         b) Isotropic:  ||HX||_{1,1}  := ||(HhX, HvX)||_11,
%             where   |||(A,B)||_{1,1} := |||sqrt(A.^2 + B.^2)||_{1,1}
%
%
% -------------------------------------------------------------------------
%
%
%
%    CONSTRAINTS ACCEPTED:
%
%    1) Positivity X(:,i) >= 0, for i=1,...,N
%    2) Sum-To-One sum( X(:,i)) = 1, for for i=1,...,N
%
%
%
%% -------------------- Line of Attack  -----------------------------------
%
%  SAL_SpTV solves the above optimization problem by introducing a variable
%  splitting and then solving the resulting constrained optimization with
%  the augmented Lagrangian method.
%
%
%   The initial problem is converted into
%
%    min  (1/2) ||X-Y||^2_F  + i_R_+(X)
%     X                        + i_S(X)
%                              + lambda_tv ||HX||_{1,1};
%
%
%   where i_R_+ and i_S are the indicator functions of the set R_+ and
%   the probability simplex, respecively, applied to the columns ox X.
%
%
%  Then, we apply the following variable splitting
%
%
%    min  (1/2) ||X-Y||^2   + lambda_tv ||V2||_{1,1} + i_R_+(V3)+ i_S(X)
%  X,V1, .... V3
%
%
%     subject to:  V1  =X
%                  V2 = HV1
%                  V3 = X
%
% ------------------------------------------------------------------------
%%  ===== Required inputs =============
%  Y - matrix with  L(observation) x N(pixels),here  is the probability matrix P_smlr in our paper.
%  Training_Info is the matrix with 0 and 1, whiche indicates the position
%  of the training samples
%%  ====================== Optional inputs =============================
%  'LAMBDA_TV' - regularization parameter for TV norm.
%                Default: 0;
%
%  'TV_TYPE'   - {'iso','niso'} type of total variation:  'iso' ==
%                isotropic; 'n-iso' == non-isotropic; Default: 'niso'
%
%  'IM_SIZE'   - [nlins, ncols]   number of lines and rows of the
%                spectral cube. These parameters are mandatory when
%                'LAMBDA_TV' is  passed.
%                Note:  n_lin*n_col = N
%
%
%  'AL_ITERS' - (double):   Minimum number of augmented Lagrangian iterations
%                           Default 100;
%
%
%  'MU' - (double):   augmented Lagrangian weight
%                           Default 0.001;
%
%
%
%  'POSITIVITY'  = {'yes', 'no'}; Default 'no'
%                  Enforces the positivity constraint: x >= 0
%
%  'ADDONE'  = {'yes', 'no'}; Default 'no'
%               Enforces the positivity constraint: x >= 0
%
%
%  'VERBOSE'   = {'yes', 'no'}; Default 'no'
%
%                 'no' - work silently
%                 'yes' - display warnings
%
%%  =========================== Outputs ==================================
% U  =  [nxN] estimated  marginal matrix corresponding to q in the paper
% test for number of required parametres

%% Using the code should cite the following papers
%(1) Le Sun, Zebin Wu, Jianjun Liu, Liang Xiao, Zhihui Wei.Supervised Spectral-Spatial Hyperspectral Image Classification
%With Weighted Markov Random Fields. IEEE T. Geoscience and Remote Sensing, 53(3): 1490-1503 (2015).
%(2) Le Sun, Zenbin Wu, Jianjun Liu, Zhihui Wei:Supervised hyperspectral image classification using sparse logistic regression
% and spatial-TV regularization. IGARSS 2013: 1019-1022.
%--------------------------------------------------------------
if (nargin-length(varargin)) ~= 2
    error('Wrong number of required parameters');
end
% data set size
[L,N] = size(Y);
n =L;

%%
%--------------------------------------------------------------
% Set the defaults for the optional parameters
%--------------------------------------------------------------
% 'LAMBDA_TV'
%  TV regularization
reg_TV = 0; % absent
im_size = []; % image size
tv_type = 'niso'; % non-isotropic TV

% 'AL:ITERS'
% maximum number of AL iteration
AL_iters = 1000;

% 'MU'
% AL weight
mu = 0.001;

% 'VERBOSE'
% display only sunsal warnings
verbose = 'off';

% 'POSITIVITY'
%
% initialization
U0 = 0;

%%
%--------------------------------------------------------------
% Read the optional parameters
%--------------------------------------------------------------
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'LAMBDA_TV'
                lambda_TV = varargin{i+1};
                if lambda_TV < 0
                    error('lambda must be non-negative');
                elseif lambda_TV > 0
                    reg_TV = 1;
                end
            case 'TV_TYPE'
                tv_type = varargin{i+1};
                if ~(strcmp(tv_type,'iso') | strcmp(tv_type,'niso'))
                    error('wrong TV_TYPE');
                end
            case 'IM_SIZE'
                im_size = varargin{i+1};
            case 'AL_ITERS'
                AL_iters = round(varargin{i+1});
                if (AL_iters <= 0 )
                    error('AL_iters must a positive integer');
                end
            case 'POSITIVITY'
                positivity = varargin{i+1};
                if strcmp(positivity,'yes')
                    reg_pos = 1;
                end
            case 'ADDONE'
                addone = varargin{i+1};
                if strcmp(addone,'yes')
                    reg_add = 1;
                end
            case 'MU'
                mu = varargin{i+1};
                if mu <= 0
                    error('mu must be positive');
                end
            case 'VERBOSE'
                verbose = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end;
    end;
end

% test for image size correctness
if reg_TV > 0
    if N ~= prod(im_size)
        error('wrong image size')
    end
    n_lin = im_size(1);
    n_col = im_size(2);
    
    % build handlers and necessary stuff
    % horizontal difference operators
    FDh = zeros(im_size);
    FDh(1,1) = -1;
    FDh(1,end) = 1;
    FDh = fft2(FDh);
    FDhH = conj(FDh);
    
    % vertical difference operator
    FDv = zeros(im_size);
    FDv(1,1) = -1;
    FDv(end,1) = 1;
    FDv = fft2(FDv);
    FDvH = conj(FDv);
    
    IL = 1./( FDhH.* FDh + FDvH.* FDv + 1);
    
    Dh = @(x) real(ifft2(fft2(x).*FDh));
    DhH = @(x) real(ifft2(fft2(x).*FDhH));
    
    Dv = @(x) real(ifft2(fft2(x).*FDv));
    DvH = @(x) real(ifft2(fft2(x).*FDvH));
    
end
%%
%---------------------------------------------
% just least squares
%---------------------------------------------
if ~reg_TV  && ~reg_pos && ~reg_add
    U = Y;
    res = norm(X-Y,'fro');
    return
end
%---------------------------------------------
% just ADDONE constrained (sum(x) = 1)
%---------------------------------------------
SMALL = 1e-12;
B = ones(1,n);
a = ones(1,N);

if  ~reg_TV  && ~reg_pos && reg_add
    % test if F is invertible
    if rcond(F) > SMALL
        % compute the solution explicitly
        U = Y- B'*inv(B*B')*(B*Y-a);
        res = norm(U-Y,'fro');
        return
    end
end
%%
%---------------------------------------------
%  Constants and initializations
%---------------------------------------------
V1_im = zeros([im_size n]);
% number of regularizers
n_reg = 3;

IF = (1/(1+ n_reg)*eye(n));

%%
%---------------------------------------------
%  Initializations
%---------------------------------------------
% no intial solution supplied
if U0 == 0
    U = IF*Y; % initialization, maybe another value, such as, U = Y;
end

% initialize V variables(V1,V2,V3)
V = cell(n_reg,1);
% initialize D variables (scaled Lagrange Multipliers)
D = cell(n_reg,1);

%  V1 data term (always present)
V{1} = U;         % V1
D{1} = zeros(size(Y));  % Lagrange multipliers
%  TV
% NOTE: V2, D2 are represented as image planes
if reg_TV == 1
    % V2
    % convert X into a cube
    U_im = reshape(U',im_size(1), im_size(2),n);
    
    V{2} = cell(n,2); % 
    D{2} = cell(n,2); % 
    for i=1:n
        % build V2 image planes
        V{2}{i}{1} = Dh(U_im(:,:,i));   % horizontal differences
        V{2}{i}{2} = Dv(U_im(:,:,i));   % horizontal differences
        % build d2 image planes
        D{2}{i}{1} = zeros(im_size);   % horizontal differences
        D{2}{i}{2} = zeros(im_size);   % horizontal differences
    end
    clear U_im;
end

% V3
% POSITIVITY
V{3} = U;
D{3} = zeros(size(U));
%%
%---------------------------------------------
%  AL iterations - main body
%---------------------------------------------
tol1 = sqrt(N)*1e-5;
i=1;
res = inf;
while (i <= AL_iters) && (sum(abs(res)) > tol1)
    % solve the quadratic step (all terms depending on U)
    Xi = (V{1}+D{1}+V{3}+D{3});
    n_aux = 1/(1+2*mu).*(Y + mu.*Xi);  %Eq.17
    % addone  (project on the affine space sum(x) = 1)  (U)
    %U = U./repmat(sum(U),n,1);
    U = n_aux + repmat((1-sum(n_aux))/n,n,1); 
    
    %fix the training samples
    U(:,Training_Info.index) = Training_Info.Traning_logic_matrix;
    
    %  Compute the Mourau proximity operators
    %  data term (V1)
    nu_aux = U - D{1};
    nu_aux_im = reshape(nu_aux',im_size(1), im_size(2),n);
    for k=1:n
        %V1
        V1_im(:,:,k) = real(ifft2(IL.*fft2(DhH(V{2}{k}{1}+D{2}{k}{1}) ...
            +  DvH(V{2}{k}{2}+D{2}{k}{2}) +  nu_aux_im(:,:,k))));
        % V2
        aux_h = Dh(V1_im(:,:,k));  %HV1
        aux_v = Dv(V1_im(:,:,k));
        if strcmp(tv_type, 'niso')  % non-isotropic TV
            V{2}{k}{1} = soft(aux_h - D{2}{k}{1}, lambda_TV/mu);   %horizontal
            V{2}{k}{2} = soft(aux_v - D{2}{k}{2}, lambda_TV/mu);   %vertical
        else    % isotropic TV
            % Vectorial soft threshold
            aux = max(sqrt((aux_h - D{2}{k}{1}).^2 + (aux_v - D{2}{k}{2}).^2)-lambda_TV/mu,0);
            V{2}{k}{1} = aux./(aux+lambda_TV/mu).*(aux_h - D{2}{k}{1});
            V{2}{k}{2} = aux./(aux+lambda_TV/mu).*(aux_v - D{2}{k}{2});
        end
        % update D2
        D{2}{k}{1} =  D{2}{k}{1} - aux_h + V{2}{k}{1};
        D{2}{k}{2} =  D{2}{k}{2} - aux_v + V{2}{k}{2};
    end
    % convert V1 to matrix format
    V{1} = reshape(V1_im, prod(im_size),n)';
    
    %  positivity   (V2)
    V{3} = max(U-D{3},0);
    % update Lagrange multipliers
    % D1
    D{1} = D{1} - U + V{1};
    % D3
    D{3} = D{3} - U + V{3};
    % compute residuals
    if mod(i,10) == 1
        st = [];
        res = norm(U-Y,'fro');
        st = strcat(st,sprintf('  res(%i) = %2.6f',res ));
        if  strcmp(verbose,'yes')
            fprintf(strcat(sprintf('iter = %i -',i),st,'\n'));
        end
    end
    i=i+1;
end
