function [M, Minit, output] = cp_apr(X, R, varargin)
%CP_APR Compute nonnegative CP with alternating Poisson regression.
%
%   M = CP_APR(X, R) computes an estimate of the best rank-R CP model of a
%   nonnegative tensor X using an alternating Poisson regression. This is
%   most appropriate for sparse count data (i.e., nonnegative integer
%   values) because it uses Kullback-Liebler divergence.  The input X can
%   be a tensor or sptensor. The result M is a ktensor.  Input data must be
%   nonnegative, and the computed ktensor factors are all nonnegative.   
%
%   Different algorithm variants are available (selected by the 'alg'
%   parameter):
%     'pqnr' - row subproblems by projected quasi-Newton (default)
%     'pdnr' - row subproblems by projected damped Hessian
%     'mu'   - multiplicative update (default in version 2.5)
%
%   M = CP_APR(X, R, 'param', value, ...) specifies optional parameters and
%   values. Some parameters work in all situations, others apply only for
%   a particular choice of algorithm.
%
%   Valid parameters and their default values are:
%      'alg'           - Algorithm ['mu'|'pdnr'|'pqnr'] {'pqnr'}
%      'stoptol'       - Tolerance on the overall KKT violation {1.0e-4}
%      'stoptime'      - Maximum number of seconds to run {1e6}
%      'maxiters'      - Maximum number of iterations {1000}
%      'init'          - Initial guess [{'random'}|ktensor]
%      'maxinneriters' - Maximum inner iterations per outer iteration {10}
%      'epsDivZero'    - Safeguard against divide by zero {1.0e-10}
%      'printitn'      - Print every n outer iterations; 0 for none {1}
%      'printinneritn' - Print every n inner iterations {0}
%
%   Additional input parameters for algorithm 'mu':
%      'kappa'         - Offset to fix complementary slackness {100}
%      'kappatol'      - Tolerance on complementary slackness {1.0e-10}
%
%   Additional input parameters for algorithm 'pdnr':
%      'epsActive'     - Bertsekas tolerance for active set {1.0e-8}
%      'mu0'           - Initial damping parameter {1.0e-5}
%      'precompinds'   - Precompute sparse tensor indices {true}
%      'inexact'       - Compute inexact Newton steps {true}
%
%   Additional input parameters for algorithm 'pqnr':
%      'epsActive'     - Bertsekas tolerance for active set {1.0e-8}
%      'lbfgsMem'      - Number vector pairs to store for L-BFGS {3}
%      'precompinds'   - Precompute sparse tensor indices {true}
%
%   [M,M0] = CP_APR(...) also returns the initial guess.
%
%   [M,M0,out] = CP_APR(...) also returns additional output:
%      out.kktViolations - maximum KKT violation per iteration
%      out.nInnerIters   - number of inner iterations per outer iteration
%      out.obj           - final negative log-likelihood objective
%      out.ttlTime       - time algorithm took to converge or reach max
%      out.times         - cumulative time through each outer iteration
%    If algorithm is 'mu':
%      out.nViolations   - number of factor matrices needing complementary
%                          slackness adjustment per iteration
%    If algorithm is 'pdnr' or 'pqnr':
%      out.nZeros        - number of zero factor entries per iteration
%
%   REFERENCES: 
%   * E. C. Chi and T. G. Kolda. On Tensors, Sparsity, and Nonnegative
%     Factorizations, SIAM J. Matrix Analysis,  33(4):1272-1299, Dec. 2012,
%     http://dx.doi.org/10.1137/110859063  
%   * S. Hansen, T. Plantenga and T. G. Kolda, Newton-Based Optimization
%     for Kullback-Leibler Nonnegative Tensor Factorizations, 
%     Optimization Methods and Software, 2015, 
%     http://dx.doi.org/10.1080/10556788.2015.1009977
%
%   See also CP_ALS, KTENSOR, TENSOR, SPTENSOR.
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt


%% Set the algorithm choice and initial guess from input or defaults.
params = inputParser;
params.addParameter('alg', 'pqnr', @(x) (ismember(x,{'mu','pdnr','pqnr'})) );
params.addParameter('init','random', @(x) (isa(x,'ktensor') || ismember(x,{'random'})) );
params.KeepUnmatched = true;
params.parse(varargin{:});

alg   = params.Results.alg;
Minit = params.Results.init;

% Extract the number of modes in tensor X.
N = ndims(X);

if (R <= 0)
    error('Number of components requested must be positive');
end

%% Check that the data is nonnegative.
tmp = find(X < 0.0);
if (size(tmp,1) > 0)
    error('Data tensor must be nonnegative for Poisson-based factorization');
end

%% Set up an initial guess for the factor matrices.
if isa(Minit,'ktensor')
    % User provided an initial ktensor; validate it.

    if (ndims(Minit) ~= N)
        error('Initial guess does not have the right number of modes');
    end
    if (ncomponents(Minit) ~= R)
        error('Initial guess does not have the right number of components');
    end

    for n = 1:N
        if (size(Minit,n) ~= size(X,n))
            error('Mode %d of the initial guess is the wrong size',n);
        end
        if (min(min(Minit.U{n})) < 0.0)
            error('Initial guess has negative element in mode %d',n);
        end
    end
    if (min(Minit.lambda) < 0.0)
        error('Initial guess has a negative ktensor weight');
    end

elseif strcmp(Minit,'random')
    % Choose random values for each element in the range (0,1).
    F = cell(N,1);
    for n = 1:N
        F{n} = rand(size(X,n),R);
    end
    Minit = ktensor(F);
end


%% Call a solver based on the choice of algorithm parameter, passing
%  all the other input parameters.
if strcmp(alg,'mu')
    [M, output] = tt_cp_apr_mu (X, R, Minit, params.Unmatched);
    output.params.alg = 'mu';

elseif strcmp(alg,'pdnr')
    [M, output] = tt_cp_apr_pdnr (X, R, Minit, params.Unmatched);
    output.params.alg = 'pdnr';

elseif strcmp(alg,'pqnr')
    [M, output] = tt_cp_apr_pqnr (X, R, Minit, params.Unmatched);
    output.params.alg = 'pqnr';
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Main algorithm PQNR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [M, out] = tt_cp_apr_pqnr(X, R, Minit, varargin)
%TT_CP_APR_PQNR Compute nonnegative CP with alternating Poisson regression.
%
%   tt_cp_apr_pqnr(X, R, ...) computes an estimate of the best rank-R
%   CP model of a tensor X using an alternating Poisson regression.
%   The algorithm solves "row subproblems" in each alternating subproblem,
%   using a quasi-Newton Hessian approximation.
%   The function is typically called by cp_apr.
%
%   The model is solved by nonlinear optimization, and the code literally
%   minimizes the negative of log-likelihood.  However, printouts to the
%   console reverse the sign to show maximization of log-likelihood.
%
%   The function call can specify optional parameters and values.
%   Valid parameters and their default values are:
%      'stoptol'       - Tolerance on the overall KKT violation {1.0e-4}
%      'stoptime'      - Maximum number of seconds to run {1e6}
%      'maxiters'      - Maximum number of iterations {1000}
%      'maxinneriters' - Maximum inner iterations per outer iteration {10}
%      'epsDivZero'    - Safeguard against divide by zero {1.0e-10}
%      'printitn'      - Print every n outer iterations; 0 for no printing {1}
%      'printinneritn' - Print every n inner iterations {0}
%      'epsActive'     - Bertsekas tolerance for active set {1.0e-8}
%      'lbfgsMem'      - Number vector pairs to store for L-BFGS {3}
%      'precompinds'   - Precompute sparse tensor indices to run faster {true}
%
%   Return values are:
%      M                 - ktensor model with R components
%      out.fnEvals       - number of row obj fn evaluations per outer iteration
%      out.kktViolations - maximum KKT violation per iteration
%      out.nInnerIters   - number of inner iterations per outer iteration
%      out.nZeros        - number of factor elements equal to zero per iteration
%      out.obj           - final log-likelihood objective
%                          (minimization objective is actually -1 times this)
%      out.ttlTime       - time algorithm took to converge or reach max
%      out.times         - cumulative time through each outer iteration
%
%   REFERENCE: Samantha Hansen, Todd Plantenga, Tamara G. Kolda.
%   Newton-Based Optimization for Nonnegative Tensor Factorizations,
%   arXiv:1304.4964 [math.NA], April 2013,
%   URL: http://arxiv.org/abs/1304.4964. Submitted for publication.
%
%   See also CP_APR, KTENSOR, TENSOR, SPTENSOR.
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt


%% Set algorithm parameters from input or by using defaults.
params = inputParser;
params.addParamValue('epsActive', 1e-8, @isscalar);
params.addParamValue('epsDivZero',1e-10,@isscalar);
params.addParamValue('lbfgsMem',3,@isscalar);
params.addParamValue('maxinneriters',10,@isscalar);
params.addParamValue('maxiters',1000,@(x) isscalar(x) & x > 0);
params.addParamValue('precompinds',true,@(x) isa(x,'logical'));
params.addParamValue('printinneritn',0,@isscalar);
params.addParamValue('printitn',1,@isscalar);
params.addParamValue('stoptime',1e6,@isscalar);
params.addParamValue('stoptol',1e-4,@isscalar);
params.parse(varargin{:});

%% Copy from params object.
epsActSet               = params.Results.epsActive;
epsDivZero              = params.Results.epsDivZero;
nSizeLBFGS              = params.Results.lbfgsMem;
maxInnerIters           = params.Results.maxinneriters;
maxOuterIters           = params.Results.maxiters;
precomputeSparseIndices = params.Results.precompinds;
printInnerItn           = params.Results.printinneritn;
printOuterItn           = params.Results.printitn;
stoptime                = params.Results.stoptime;
stoptol                 = params.Results.stoptol;


% Extract the number of modes in tensor X.
N = ndims(X);

% If the initial guess has any rows of all zero elements, then modify
% so the row subproblem is not taking log(0).  Values will be restored to
% zero later if the unfolded X for the row has no nonzeros.
for n = 1:N
  rowsum = sum(Minit{n},2);
  tmpIx = find(rowsum == 0);
  if (isempty(tmpIx) == false)
    Minit{n}(tmpIx,1) = 1.0e-8;
  end
end

% Start with the initial guess, normalized using the vector L1 norm.
M = normalize(Minit,[],1);

% Sparse tensor flag affects how Pi and Phi are computed.
if isa(X,'sptensor')
    isSparse = true;
else
    isSparse = false;
end

% Initialize output arrays.
fnEvals = zeros(maxOuterIters,1);
kktViolations = -ones(maxOuterIters,1);
nInnerIters = zeros(maxOuterIters,1);
nzeros = zeros(maxOuterIters,1);
times = zeros(maxOuterIters,1);

if (printOuterItn > 0)
    fprintf('\nCP_PQNR (alternating Poisson regression using quasi-Newton)\n');
end
dispLineWarn = (printInnerItn > 0);

% Start the wall clock timer.
tic;


if (isSparse && precomputeSparseIndices)
    % Precompute sparse index sets for all the row subproblems.
    % Takes more memory but can cut execution time significantly in some cases.
    if (printOuterItn > 0)
        fprintf('  Precomputing sparse index sets...');
    end
    sparseIx = cell(N);
    for n = 1:N
        num_rows = size(M{n},1);
        sparseIx{n} = cell(num_rows,1);
        for jj = 1:num_rows
            sparseIx{n}{jj} = find(X.subs(:,n) == jj);
        end
    end
    if (printOuterItn > 0)
        fprintf('done\n');
    end
end


%% Main Loop: Iterate until convergence or a max threshold is reached.
for iter = 1:maxOuterIters

    isConverged = true;  
    kktModeViolations = zeros(N,1);
    countInnerIters = zeros(1,N);

    % Alternate thru each factor matrix, A_1, A_2, ... , A_N.
    for n = 1:N

        % Shift the weight from lambda to mode n.
        M = redistribute(M,n);

        % Calculate Khatri-Rhao product of all matrices but the n-th.
        if (isSparse == false)
            % Data is not a sparse tensor.
            Pi = tt_calcpi_prowsubprob(X, isSparse, M, R, n, N, []);
            X_mat = double(tenmat(X,n));
        end

        num_rows = size(M{n},1);
        isRowNOTconverged = zeros(1,num_rows);

        % Loop over the row subproblems in mode n.
        for jj = 1:num_rows

            % Get data values for row jj of matricized mode n.
            if (isSparse)
                % Data is a sparse tensor.
                if (precomputeSparseIndices == false)
                    sparse_indices = find(X.subs(:,n) == jj);
                else
                    sparse_indices = sparseIx{n}{jj};
                end
                if (isempty(sparse_indices))
                    % The row jj of matricized tensor X in mode n is empty.
                    M{n}(jj,:) = 0;
                    continue
                end
                x_row = X.vals(sparse_indices);

                % Calculate just the columns of Pi needed for this row.
                Pi = tt_calcpi_prowsubprob(X, isSparse, M, ...
                                           R, n, N, sparse_indices);
            else
                x_row = X_mat(jj,:);
            end

            % Get current values of the row subproblem variables.
            m_row = M{n}(jj,:);

            % Initialize L-BFGS storage for the row subproblem.
            delm = zeros(R, nSizeLBFGS);
            delg = zeros(R, nSizeLBFGS);
            rho = zeros(nSizeLBFGS, 1);
            lbfgsPos = 1;
            m_rowOLD = [];
            gradOLD = [];

            % Iteratively solve the row subproblem with projected qNewton steps.
            for i = 1:maxInnerIters
                % Calculate the gradient.
                [gradM, phi_row] = calc_grad(isSparse, Pi, epsDivZero, ...
                                             x_row, m_row);

                if (i == 1)
                    % Original cp_aprPQN_row code (and plb_row) does a gradient
                    % step to prime the L-BFGS approximation.  However, it means
                    % a row subproblem that already converged wastes time
                    % doing a gradient step before checking KKT conditions.
                    % TODO: fix in a future release.
                    m_rowOLD = m_row;
                    gradOLD = gradM;
                    [m_row, f, f_unit, f_new, num_evals] ...
                        = tt_linesearch_prowsubprob(-gradM', gradM', ...
                                                    m_rowOLD, ...
                                                    1, 1/2, 10, 1.0e-4, ...
                                                    isSparse, x_row, Pi, ...
                                                    phi_row, dispLineWarn);
                    fnEvals(iter) = fnEvals(iter) + num_evals;
                    [gradM, phi_row] = calc_grad(isSparse, Pi, epsDivZero, ...
                                                 x_row, m_row);
                end

                % Compute the row subproblem kkt_violation.
                % Experiments in the original paper used this:
                %kkt_violation = norm(abs(min(m_row,gradM')),2);
                % Now we use | KKT |_inf:
                kkt_violation = max(abs(min(m_row,gradM')));

                % Report largest row subproblem initial violation.
                if ((i == 1) && (kkt_violation > kktModeViolations(n)))
                     kktModeViolations(n) = kkt_violation;
                end

                if (mod(i, printInnerItn) == 0)
                    fprintf('    Mode = %1d, Row = %d, InnerIt = %d', ...
                            n, jj, i);
                    if (i == 1)
                        fprintf(', RowKKT = %.2e\n', kkt_violation);
                    else
                        fprintf(', RowKKT = %.2e, RowObj = %.4e\n', ...
                                kkt_violation, -f_new);
                    end
                end

                % Check for row subproblem convergence.
                if (kkt_violation < stoptol)
                    break;
                else
                    % Not converged, so m_row will be modified.
                    isRowNOTconverged(jj) = 1;
                end

                % Update the L-BFGS approximation.
                tmp_delm = m_row - m_rowOLD;
                tmp_delg = gradM - gradOLD;
                tmp_rho = 1 / (tmp_delm * tmp_delg);
                if ((tmp_rho > 0.0) && (isinf(tmp_rho) == false))
                    delm(:,lbfgsPos) = tmp_delm;
                    delg(:,lbfgsPos) = tmp_delg;
                    rho(lbfgsPos) = tmp_rho;
                else
                    % Rho is required to be positive; if not, then skip
                    % the L-BFGS update pair.  The recommended safeguard for
                    % full BFGS is Powell damping, but not clear how to damp
                    % in 2-loop L-BFGS.
                    if (dispLineWarn)
                        fprintf('WARNING: skipping L-BFGS update, rho would be 1 / %.2e\n', ...
                                (tmp_delm * tmp_delg));
                    end
                    % Roll back lbfgsPos since it will increment later.
                    if (lbfgsPos == 1)
                        if (rho(nSizeLBFGS) > 0)
                            lbfgsPos = nSizeLBFGS;
                        else
                            % Fatal error, should not happen.
                            fprintf('ERROR: L-BFGS first iterate is bad\n');
                            return;
                        end
                    else
                        lbfgsPos = lbfgsPos - 1;
                    end
                end

                % Calculate the search direction.
                search_dir = getSearchDirPqnr(m_row, gradM, epsActSet, ...
                                              delm, delg, rho, lbfgsPos, ...
                                              i, dispLineWarn);
                lbfgsPos = mod(lbfgsPos, nSizeLBFGS) + 1;

                m_rowOLD = m_row;
                gradOLD = gradM;

                % Perform a projected linesearch and update variables.
                % Start from a unit step length, decrease by 1/2, stop with
                % sufficient decrease of 1.0e-4 or at most 10 steps.
                [m_row, f, f_unit, f_new, num_evals] ...
                    = tt_linesearch_prowsubprob(search_dir', gradOLD', m_rowOLD, ...
                                                1, 1/2, 10, 1.0e-4, ...
                                                isSparse, x_row, Pi, ...
                                                phi_row, dispLineWarn);
                fnEvals(iter) = fnEvals(iter) + num_evals;
            end

            M{n}(jj,:) = m_row;
            countInnerIters(n) = countInnerIters(n) + i;

        end

        % Test if all row subproblems have converged, which means that
        % no variables in this mode were changed.
        if (sum(isRowNOTconverged) ~= 0)
            isConverged = false;
        end

        % Shift weight from mode n back to lambda.
        M = normalize(M,[],1,n);

        % Total number of inner iterations for a given outer iteration,
        % totalled across all modes and all row subproblems in each mode.
        nInnerIters(iter) = nInnerIters(iter) + countInnerIters(n);
    end

    % Save output items for the outer iteration.
    num_zero = 0;
    for n = 1:N
        num_zero = num_zero + nnz(find(M{n} == 0.0));
    end
    nzeros(iter) = num_zero;
    kktViolations(iter) = max(kktModeViolations); 

    % Print outer iteration status.
    if (mod(iter,printOuterItn) == 0)
        fprintf('%4d. Ttl Inner Its: %d, KKT viol = %.2e, obj = %.8e, nz: %d\n', ...
        iter, nInnerIters(iter), kktViolations(iter), tt_loglikelihood(X,M), ...
        num_zero);
    end

    times(iter) = toc;

    % Check for convergence
    if (isConverged)
        break;
    end
    if (times(iter) > stoptime)
        fprintf('Exiting because time limit exceeded\n');
        break;
    end

end

t_stop = toc;

%% Clean up final result and set output items.
M = normalize(M,'sort',1);
loglike = tt_loglikelihood(X,M);

if (printOuterItn > 0)
    % For legacy reasons, compute "fit", the fraction explained by the model.
    % Fit is in the range [0,1], with 1 being the best fit.
    normX = norm(X);   
    normresidual = sqrt( normX^2 + norm(M)^2 - 2 * innerprod(X,M) );
    fit = 1 - (normresidual / normX);

    fprintf('===========================================\n');
    fprintf(' Final log-likelihood = %e \n', loglike);
    fprintf(' Final least squares fit = %e \n', fit);
    fprintf(' Final KKT violation = %7.7e\n', kktViolations(iter));
    fprintf(' Total inner iterations = %d\n', sum(nInnerIters));
    fprintf(' Total execution time = %.2f secs\n', t_stop);
end

out = struct;
out.params = params.Results;
out.obj = loglike;
out.kktViolations = kktViolations(1:iter);
out.fnEvals = fnEvals(1:iter);
out.nInnerIters = nInnerIters(1:iter);
out.nZeros = nzeros(1:iter);
out.times = times(1:iter);
out.ttlTime = t_stop;

end

%----------------------------------------------------------------------

function [grad_row, phi_row] = calc_grad(isSparse, Pi, eps_div_zero, x_row, m_row)
%function grad_row = calc_grad(isSparse, Pi, eps_div_zero, x_row, m_row)
% Compute the gradient for a PQNR row subproblem.
%
%   isSparse     - true if x_row is sparse, false if dense
%   Pi           - matrix
%   eps_div_zero - safeguard value to prevent division by zero
%   x_row        - row vector of data values for the row subproblem
%   m_row        - vector of variables for the row subproblem
%
%   Returns the gradient vector for a row subproblem.

    if (isSparse)
        v = m_row * Pi';
        w = x_row' ./ max(v, eps_div_zero);
        phi_row = w * Pi;
 
    else
        v = m_row * Pi';
        w = x_row ./ max(v, eps_div_zero);
        phi_row = w * Pi;
    end

    grad_row = (ones(size(phi_row)) - phi_row)';
end

%----------------------------------------------------------------------

function [d] = getSearchDirPqnr (m_row, grad, epsActSet, ...
                                 delta_m, delta_g, rho, lbfgs_pos, ...
                                 iters, disp_warn)
% Compute the search direction by projecting with L-BFGS.
%
%   m_row     - current variable values
%   grad      - gradient at m_row
%   epsActSet - Bertsekas tolerance for active set determination
%   delta_m   - L-BFGS array of vector variable deltas
%   delta_g   - L-BFGS array of gradient deltas
%   lbfgs_pos - pointer into L-BFGS arrays
%
%   Returns
%     d       - search direction based on current L-BFGS and grad
%
%   Adapted from MATLAB code of Dongmin Kim and Suvrit Sra written in 2008.
%   Modified extensively to solve row subproblems and use a better linesearch;
%   see the reference at the top of this file for details.

    lbfgsSize = size(delta_m,2);

    % Determine active and free variables.
    % If epsActSet is zero, then the following works:
    %   fixedVars = find((m_row == 0) & (grad' > 0));
    % For the general case this works but is less clear and assumes m_row > 0:
    %   fixedVars = find((grad' > 0) & (m_row <= min(epsActSet,grad')));
    projGradStep = (m_row - grad') .* (m_row - grad' > 0);
    wk = norm(m_row - projGradStep);
    fixedVars = find((grad' > 0) & (m_row <= min(epsActSet,wk)));

    d = -grad;
    d(fixedVars) = 0;

    if ((delta_m(:,lbfgs_pos)' * delta_g(:,lbfgs_pos)) == 0.0)
        % Cannot proceed with this L-BFGS data; most likely the iteration
        % has converged, so this is rarely seen.
        if (disp_warn)
            fprintf('WARNING: L-BFGS update is orthogonal, using gradient\n');
        end
        return;
    end

    alpha = ones(lbfgsSize,1);
    k = lbfgs_pos;

    % Perform an L-BFGS two-loop recursion to compute the search direction.

    for i = 1 : min(iters, lbfgsSize)
        alpha(k) = rho(k) * delta_m(:, k)' * d;
        d = d - alpha(k) * delta_g(:, k);
        k = lbfgsSize - mod(1 - k, lbfgsSize);
    end

    coef = 1 / rho(lbfgs_pos) / (delta_g(:, lbfgs_pos)' * delta_g(:, lbfgs_pos));
    d = coef * d;

    for i = 1 : min(iters, lbfgsSize)
        k = mod(k, lbfgsSize) + 1;
        b = rho(k) * delta_g(:, k)' * d;
        d = d + (alpha(k) - b) * delta_m(:, k);
    end

    d(fixedVars) = 0;

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Main algorithm PDNR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [M, out] = tt_cp_apr_pdnr(X, R, Minit, varargin)
%TT_CP_APR_PDNR Compute nonnegative CP with alternating Poisson regression.
%
%   tt_cp_apr_pdnr(X, R, ...) computes an estimate of the best rank-R
%   CP model of a tensor X using an alternating Poisson regression.
%   The algorithm solves "row subproblems" in each alternating subproblem,
%   using a Hessian of size R^2.
%   The function is typically called by cp_apr.
%
%   The model is solved by nonlinear optimization, and the code literally
%   minimizes the negative of log-likelihood.  However, printouts to the
%   console reverse the sign to show maximization of log-likelihood.
%
%   The function call can specify optional parameters and values.
%   Valid parameters and their default values are:
%      'stoptol'       - Tolerance on the overall KKT violation {1.0e-4}
%      'stoptime'      - Maximum number of seconds to run {1e6}
%      'maxiters'      - Maximum number of iterations {1000}
%      'maxinneriters' - Maximum inner iterations per outer iteration {10}
%      'epsDivZero'    - Safeguard against divide by zero {1.0e-10}
%      'printitn'      - Print every n outer iterations; 0 for no printing {1}
%      'printinneritn' - Print every n inner iterations {0}
%      'epsActive'     - Bertsekas tolerance for active set {1.0e-8}
%      'mu0'           - Initial damping parameter {1.0e-5}
%      'precompinds'   - Precompute sparse tensor indices to run faster {true}
%      'inexact'       - Compute inexact Newton steps {true}
%
%   Return values are:
%      M                 - ktensor model with R components
%      out.fnEvals       - number of row obj fn evaluations per outer iteration
%      out.kktViolations - maximum KKT violation per iteration
%      out.nInnerIters   - number of inner iterations per outer iteration
%      out.nZeros        - number of factor elements equal to zero per iteration
%      out.obj           - final log-likelihood objective
%                          (minimization objective is actually -1 times this)
%      out.ttlTime       - time algorithm took to converge or reach max
%      out.times         - cumulative time through each outer iteration
%
%   REFERENCE: Samantha Hansen, Todd Plantenga, Tamara G. Kolda.
%   Newton-Based Optimization for Nonnegative Tensor Factorizations,
%   arXiv:1304.4964 [math.NA], April 2013,
%   URL: http://arxiv.org/abs/1304.4964. Submitted for publication.
%
%   See also CP_APR, KTENSOR, TENSOR, SPTENSOR.
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt


%% Set algorithm parameters from input or by using defaults.
params = inputParser;
params.addParamValue('epsActive', 1e-8, @isscalar);
params.addParamValue('epsDivZero',1e-10,@isscalar);
params.addParamValue('maxinneriters',10,@isscalar);
params.addParamValue('maxiters',1000,@(x) isscalar(x) & x > 0);
params.addParamValue('precompinds',true,@(x) isa(x,'logical'));
params.addParamValue('inexact',true,@(x) isa(x,'logical'));
params.addParamValue('mu0',1e-5,@isscalar);
params.addParamValue('printinneritn',0,@isscalar);
params.addParamValue('printitn',1,@isscalar);
params.addParamValue('stoptime',1e6,@isscalar);
params.addParamValue('stoptol',1e-4,@isscalar);
params.parse(varargin{:});

%% Copy from params object.
epsActSet               = params.Results.epsActive;
epsDivZero              = params.Results.epsDivZero;
maxInnerIters           = params.Results.maxinneriters;
maxOuterIters           = params.Results.maxiters;
mu0                     = params.Results.mu0;
precomputeSparseIndices = params.Results.precompinds;
inexactNewton           = params.Results.inexact;
printInnerItn           = params.Results.printinneritn;
printOuterItn           = params.Results.printitn;
stoptime                = params.Results.stoptime;
stoptol                 = params.Results.stoptol;


% Extract the number of modes in tensor X.
N = ndims(X);

% If the initial guess has any rows of all zero elements, then modify
% so the row subproblem is not taking log(0).  Values will be restored to
% zero later if the unfolded X for the row has no nonzeros.
for n = 1:N
  rowsum = sum(Minit{n},2);
  tmpIx = find(rowsum == 0);
  if (isempty(tmpIx) == false)
    Minit{n}(tmpIx,1) = 1.0e-8;
  end
end

% Start with the initial guess, normalized using the vector L1 norm.
M = normalize(Minit,[],1);

% Sparse tensor flag affects how Pi and Phi are computed.
if isa(X,'sptensor')
    isSparse = true;
else
    isSparse = false;
end

% Initialize output arrays.
fnEvals = zeros(maxOuterIters,1);
kktViolations = -ones(maxOuterIters,1);
nInnerIters = zeros(maxOuterIters,1);
nzeros = zeros(maxOuterIters,1);
times = zeros(maxOuterIters,1);

if (printOuterItn > 0)
    fprintf('\nCP_PDNR (alternating Poisson regression using damped Newton)\n');
end
dispLineWarn = (printInnerItn > 0);

% Start the wall clock timer.
tic;


if (isSparse && precomputeSparseIndices)
    % Precompute sparse index sets for all the row subproblems.
    % Takes more memory but can cut execution time significantly in some cases.
    if (printOuterItn > 0)
        fprintf('  Precomputing sparse index sets...');
    end
    sparseIx = cell(N);
    for n = 1:N
        num_rows = size(M{n},1);
        sparseIx{n} = cell(num_rows,1);
        for jj = 1:num_rows
            sparseIx{n}{jj} = find(X.subs(:,n) == jj);
        end
    end
    if (printOuterItn > 0)
        fprintf('done\n');
    end
end

e_vec = ones(1,R);

rowsubprobStopTol = stoptol;

%% Main Loop: Iterate until convergence or a max threshold is reached.
for iter = 1:maxOuterIters

    isConverged = true;  
    kktModeViolations = zeros(N,1);
    countInnerIters = zeros(1,N);

    % Alternate thru each factor matrix, A_1, A_2, ... , A_N.
    for n = 1:N

        % Shift the weight from lambda to mode n.
        M = redistribute(M,n);

        % Calculate Khatri-Rhao product of all matrices but the n-th.
        if (isSparse == false)
            % Data is not a sparse tensor.
            Pi = tt_calcpi_prowsubprob(X, isSparse, M, R, n, N, []);
            X_mat = double(tenmat(X,n));
        end

        num_rows = size(M{n},1);
        isRowNOTconverged = zeros(1,num_rows);

        % Loop over the row subproblems in mode n.
        for jj = 1:num_rows
            % Initialize the damped Hessian parameter for the row subproblem.
            mu = mu0;

            % Get data values for row jj of matricized mode n.
            if (isSparse)
                % Data is a sparse tensor.
                if (precomputeSparseIndices == false)
                    sparse_indices = find(X.subs(:,n) == jj);
                else
                    sparse_indices = sparseIx{n}{jj};
                end
                if (isempty(sparse_indices))
                    % The row jj of matricized tensor X in mode n is empty.
                    M{n}(jj,:) = 0;
                    continue
                end
                x_row = X.vals(sparse_indices);

                % Calculate just the columns of Pi needed for this row.
                Pi = tt_calcpi_prowsubprob(X, isSparse, M, ...
                                           R, n, N, sparse_indices);
            else
                x_row = X_mat(jj,:);
            end

            % Get current values of the row subproblem variables.
            m_row = M{n}(jj,:);

            % Iteratively solve the row subproblem with projected Newton steps.
            innerIterMaximum = maxInnerIters;
            if (inexactNewton && (iter == 1))
                innerIterMaximum = 2;
            end
            for i = 1:innerIterMaximum
                % Calculate the gradient.
                [phi_row, ups_row] ...
                    = calc_partials(isSparse, Pi, epsDivZero, x_row, m_row);
                gradM = (e_vec - phi_row)';

                % Compute the row subproblem kkt_violation.
                % Experiments in the original paper used this:
                %kkt_violation = norm(abs(min(m_row,gradM')),2);
                % Now we use | KKT |_inf:
                kkt_violation = max(abs(min(m_row,gradM')));

                % Report largest row subproblem initial violation.
                if ((i == 1) && (kkt_violation > kktModeViolations(n)))
                     kktModeViolations(n) = kkt_violation;
                end

                if (mod(i, printInnerItn) == 0)
                    fprintf('    Mode = %1d, Row = %d, InnerIt = %d', ...
                            n, jj, i);
                    if (i == 1)
                        fprintf(', RowKKT = %.2e\n', kkt_violation);
                    else
                        fprintf(', RowKKT = %.2e, RowObj = %.4e\n', ...
                                kkt_violation, -f_new);
                    end
                end

                % Check for row subproblem convergence.
                if (kkt_violation < rowsubprobStopTol)
                    break;
                else
                    % Not converged, so m_row will be modified.
                    isRowNOTconverged(jj) = 1;
                end

                % Calculate the search direction.
                [search_dir, predicted_red] ...
                    = getSearchDirPdnr(Pi, ups_row, R, gradM, m_row, mu, epsActSet);

                % Perform a projected linesearch and update variables.
                % Start from a unit step length, decrease by 1/2, stop with
                % sufficient decrease of 1.0e-4 or at most 10 steps.
                [m_rowNEW, f_old, f_unit, f_new, num_evals] ...
                    = tt_linesearch_prowsubprob(search_dir', gradM', m_row, ...
                                                1, 1/2, 10, 1.0e-4, ...
                                                isSparse, x_row, Pi, ...
                                                phi_row, dispLineWarn);
                fnEvals(iter) = fnEvals(iter) + num_evals;
                m_row = m_rowNEW;

                % Update damping parameter mu based on the unit step length,
                % which is returned in f_unit.
                actual_red = f_old - f_unit;
                rho = actual_red / (-predicted_red);
                if (predicted_red == 0)
                    mu = 10 * mu;
                elseif (rho < 1/4)
                    mu = (7/2) * mu;
                elseif (rho > 3/4)
                    mu = (2/7) * mu;
                end
            end

            M{n}(jj,:) = m_row;
            countInnerIters(n) = countInnerIters(n) + i;

        end

        % Test if all row subproblems have converged, which means that
        % no variables in this mode were changed.
        if (sum(isRowNOTconverged) ~= 0)
            isConverged = false;
        end

        % Shift weight from mode n back to lambda.
        M = normalize(M,[],1,n);

        % Total number of inner iterations for a given outer iteration,
        % totalled across all modes and all row subproblems in each mode.
        nInnerIters(iter) = nInnerIters(iter) + countInnerIters(n);
    end

    % Save output items for the outer iteration.
    num_zero = 0;
    for n = 1:N
        num_zero = num_zero + nnz(find(M{n} == 0.0));
    end
    nzeros(iter) = num_zero;
    kktViolations(iter) = max(kktModeViolations);
    if (inexactNewton)
        rowsubprobStopTol = max(stoptol, kktViolations(iter) / 100.0);
    end

    % Print outer iteration status.
    if (mod(iter,printOuterItn) == 0)
        fprintf('%4d. Ttl Inner Its: %d, KKT viol = %.2e, obj = %.8e, nz: %d\n', ...
        iter, nInnerIters(iter), kktViolations(iter), tt_loglikelihood(X,M), ...
        num_zero);
    end

    times(iter) = toc;

    % Check for convergence
    if (isConverged && (inexactNewton == false))
        break;
    end
    if (isConverged && (inexactNewton == true) && (rowsubprobStopTol <= stoptol))
        break;
    end
    if (times(iter) > stoptime)
        fprintf('Exiting because time limit exceeded\n');
        break;
    end

end

t_stop = toc;

%% Clean up final result and set output items.
M = normalize(M,'sort',1);
loglike = tt_loglikelihood(X,M);

if (printOuterItn > 0)
    % For legacy reasons, compute "fit", the fraction explained by the model.
    % Fit is in the range [0,1], with 1 being the best fit.
    normX = norm(X);   
    normresidual = sqrt( normX^2 + norm(M)^2 - 2 * innerprod(X,M) );
    fit = 1 - (normresidual / normX);

    fprintf('===========================================\n');
    fprintf(' Final log-likelihood = %e \n', loglike);
    fprintf(' Final least squares fit = %e \n', fit);
    fprintf(' Final KKT violation = %7.7e\n', kktViolations(iter));
    fprintf(' Total inner iterations = %d\n', sum(nInnerIters));
    fprintf(' Total execution time = %.2f secs\n', t_stop);
end

out = struct;
out.params = params.Results;
out.obj = loglike;
out.kktViolations = kktViolations(1:iter);
out.fnEvals = fnEvals(1:iter);
out.nInnerIters = nInnerIters(1:iter);
out.nZeros = nzeros(1:iter);
out.times = times(1:iter);
out.ttlTime = t_stop;

end

%----------------------------------------------------------------------

function [phi_row, ups_row] ...
    = calc_partials(isSparse, Pi, eps_div_zero, x_row, m_row)
% Compute derivative quantities for a PDNR row subproblem.
%
%   isSparse     - true if x_row is sparse, false if dense
%   Pi           - matrix
%   eps_div_zero - safeguard value to prevent division by zero
%   x_row        - row vector of data values for the row subproblem
%   m_row        - vector of variables for the row subproblem
%
%   Returns two vectors for a row subproblem:
%     phi_row - gradient of row subproblem, except for a constant
%     ups_row - intermediate quantity (upsilon) used for second derivatives

    if (isSparse)
        v = m_row * Pi';
        w = x_row' ./ max(v, eps_div_zero);
        phi_row = w * Pi;
        u = v .^ 2;
        ups_row = x_row' ./ max(u, eps_div_zero);
 
    else
        v = m_row * Pi';
        w = x_row ./ max(v, eps_div_zero);
        phi_row = w * Pi;
        u = v .^ 2;
        ups_row = x_row ./ max(u, eps_div_zero);
    end

end


%----------------------------------------------------------------------

function H = getHessian(upsilon, Pi, free_indices)
% Return the Hessian for one PDNR row subproblem of M{n}, for just the rows and
% columns corresponding to the free variables.
    
    num_free = length(free_indices);
    H = zeros(num_free,num_free);
    for i = 1:num_free
        for j = i:num_free
            c = free_indices(i);
            d = free_indices(j);
            val = sum(upsilon' .* Pi(:,c) .* Pi(:,d));
            H(i,j) = val;
            H(j,i) = val;
        end
    end

end

%----------------------------------------------------------------------

function [search_dir, pred_red] ...
    = getSearchDirPdnr (Pi, ups_row, R, gradM, m_row, mu, epsActSet)
% Compute the search direction for PDNR using a two-metric projection
% with damped Hessian.
%
%   Pi        - matrix
%   ups_row   - intermediate quantity (upsilon) used for second derivatives
%   R         - number of variables for the row subproblem
%   gradM     - gradient vector for the row subproblem
%   m_row     - vector of variables for the row subproblem
%   mu        - damping parameter
%   epsActSet - Bertsekas tolerance for active set determination
%
%   Returns:
%     search_dir - search direction vector
%     pred_red   - predicted reduction in quadratic model

    search_dir = zeros(R,1);
    projGradStep = (m_row - gradM') .* (m_row - gradM' > 0);
    wk = norm(m_row - projGradStep);

    % Determine active and free variables.
    num_free = 0;
    free_indices_tmp = zeros(R,1);
    for r = 1:R
        if ((m_row(r) <= min(epsActSet,wk)) && (gradM(r) > 0) )
            % Variable is not free (belongs to set A or G).
            if (m_row(r) ~= 0)
                % Variable moves according to the gradient (set G).
                search_dir(r) = -gradM(r);
            end
        else
            % Variable is free (set F).
            num_free = num_free + 1;
            free_indices_tmp(num_free) = r;
        end
    end 
    free_indices = free_indices_tmp(1:num_free);

    % Compute the Hessian for free variables.
    Hessian_free = getHessian(ups_row, Pi, free_indices);
    grad_free = -gradM(free_indices);

    % Compute the damped Newton search direction over free variables.
    search_dir(free_indices) ...
        = linsolve(Hessian_free + (mu * eye(num_free)), grad_free); 

    % If the Hessian is too ill-conditioned, use gradient descent.
    [~, msgid] = lastwarn('MATLAB:noWarning'); 
    if (strcmp(msgid,'MATLAB:nearlySingularMatrix'))
        fprintf('WARNING: damped Hessian is nearly singular\n');
        search_dir = -gradM;
    end

    % Calculate expected reduction in the quadratic model of the objective.
    q = search_dir(free_indices)' ...
        * (Hessian_free + (mu * eye(num_free))) ...
        * search_dir(free_indices);
    pred_red = (search_dir(free_indices)' * gradM(free_indices)) + (0.5 * q);
    if (pred_red > 0)
        fprintf('ERROR: expected decrease is positive\n');
        search_dir = -gradM;
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Main algorithm MU
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [M, output] = tt_cp_apr_mu(X, R, Minit, varargin)
%TT_CP_APR_MU Compute nonnegative CP with alternating Poisson regression.
%
%   tt_cp_apr_mu(X, R, ...) computes an estimate of the best rank-R
%   CP model of a tensor X using an alternating Poisson regression.
%   The algorithm solves each alternating subproblem using multiplicative
%   updates with adjustments for values near zero.
%   The function is typically called by cp_apr.
%
%   The function call can specify optional parameters and values.
%   Valid parameters and their default values are:
%      'stoptol'       - Tolerance on the overall KKT violation {1.0e-4}
%      'stoptime'      - Maximum number of seconds to run {1e6}
%      'maxiters'      - Maximum number of iterations {1000}
%      'maxinneriters' - Maximum inner iterations per outer iteration {10}
%      'epsDivZero'    - Safeguard against divide by zero {1.0e-10}
%      'printitn'      - Print every n outer iterations; 0 for no printing {1}
%      'printinneritn' - Print every n inner iterations {0}
%      'kappatol'      - Tolerance on complementary slackness {1.0e-10}
%      'kappa'         - Offset to fix complementary slackness {100}
%
%   Return values are:
%      M                 - ktensor model with R components
%      out.kktViolations - maximum KKT violation per iteration
%      out.nInnerIters   - number of inner iterations per outer iteration
%      out.nViolations   - number of factor matrices needing complementary
%                          slackness adjustment per iteration
%      out.obj           - final log-likelihood objective
%      out.ttlTime       - time algorithm took to converge or reach max
%      out.times         - cumulative time through each outer iteration
%
%   REFERENCE: E. C. Chi and T. G. Kolda. On Tensors, Sparsity, and
%   Nonnegative Factorizations, arXiv:1112.2414 [math.NA], December 2011,
%   URL: http://arxiv.org/abs/1112.2414. Submitted for publication.
%
%   See also CP_APR, KTENSOR, TENSOR, SPTENSOR.
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt


%% Set algorithm parameters from input or by using defaults.
params = inputParser;
params.addParamValue('epsDivZero',1e-10,@isscalar);
params.addParamValue('kappa',1e-2,@isscalar);
params.addParamValue('kappatol',1e-10,@isscalar);
params.addParamValue('maxinneriters',10,@isscalar);
params.addParamValue('maxiters',1000,@(x) isscalar(x) & x > 0);
params.addParamValue('printinneritn',0,@isscalar);
params.addParamValue('printitn',1,@isscalar);
params.addParamValue('stoptime',1e6,@isscalar);
params.addParamValue('stoptol',1e-4,@isscalar);
params.parse(varargin{:});


%% Extract dimensions of X and number of dimensions of X.
N = ndims(X);

%% Copy from params object.
epsilon       = params.Results.epsDivZero;
tol           = params.Results.stoptol;
stoptime      = params.Results.stoptime;
maxOuterIters = params.Results.maxiters;
kappa         = params.Results.kappa;
kappaTol      = params.Results.kappatol;
maxInnerIters = params.Results.maxinneriters;
printOuterItn = params.Results.printitn;
printInnerItn = params.Results.printinneritn;
kktViolations = -ones(maxOuterIters,1);
nInnerIters   = zeros(maxOuterIters,1);
times         = zeros(maxOuterIters,1);

%% Set up and error checking on initial guess for U.
if isa(Minit,'ktensor')
    if ndims(Minit) ~= N
        error('Initial guess does not have the right number of dimensions');
    end
    
    if ncomponents(Minit) ~= R
        error('Initial guess does not have the right number of components');
    end
    
    for n = 1:N
        if size(Minit,n) ~= size(X,n)
            error('Dimension %d of the initial guess is the wrong size',n);
        end
    end
elseif strcmp(Minit,'random')
    F = cell(N,1);
    for n = 1:N
        F{n} = rand(size(X,n),R);
    end
    Minit = ktensor(F);
else
    error('The selected initialization method is not supported');
end


%% Set up for iterations - initializing M and Phi.
M = normalize(Minit,[],1);
Phi = cell(N,1);
kktModeViolations = zeros(N,1);

if printOuterItn > 0
  fprintf('\nCP_APR:\n');
end

nViolations = zeros(maxOuterIters,1);

% Start the wall clock timer.
tic;

% PDN-R and PQN-R benefit from precomputing sparse indices of X for each
% mode subproblem.  However, MU execution time barely changes, so the
% precompute option is not offered.


%% Main Loop: Iterate until convergence.
for iter = 1:maxOuterIters
    
    isConverged = true;   
    for n = 1:N

        % Make adjustments to entries of M{n} that are violating
        % complementary slackness conditions.
        if (iter > 1)
            V = (Phi{n} > 1) & (M{n} < kappaTol);
            if any(V(:))           
                nViolations(iter) = nViolations(iter) + 1;
                M{n}(V>0) = M{n}(V>0) + kappa;
            end
        end         

        % Shift the weight from lambda to mode n
        M = redistribute(M,n);
        
        % Calculate product of all matrices but the n-th
        % (Sparse case only calculates entries corresponding to nonzeros in X)
        Pi = calculatePi(X, M, R, n, N);
        
        % Do the multiplicative updates
        for i = 1:maxInnerIters

            % Count the inner iterations
            nInnerIters(iter) = nInnerIters(iter) + 1;
                                  
            % Calculate matrix for multiplicative update
            Phi{n} = calculatePhi(X, M, R, n, Pi, epsilon);
            
            % Check for convergence
            kktModeViolations(n) = max(abs(vectorizeForMu(min(M.U{n},1-Phi{n}))));
            if (kktModeViolations(n) < tol)
                break;
            else
                isConverged = false;
            end                      
            
            % Do the multiplicative update
            M{n} = M{n} .* Phi{n};
            
            % Print status
             if mod(i, printInnerItn)==0
                 fprintf('    Mode = %1d, Inner Iter = %2d, KKT violation = %.6e\n', n, i, kktModeViolations(n));
             end
        end
        
        % Shift weight from mode n back to lambda
        M = normalize(M,[],1,n);
        
    end

    kktViolations(iter) = max(kktModeViolations);    

    if (mod(iter,printOuterItn)==0)
        fprintf(' Iter %4d: Inner Its = %2d KKT violation = %.6e, nViolations = %2d\n', ...
        iter, nInnerIters(iter), kktViolations(iter), nViolations(iter));            
    end
    times(iter) = toc;
    
    % Check for convergence
    if (isConverged)
        if printOuterItn>0
            fprintf('Exiting because all subproblems reached KKT tol.\n');
        end
        break;
    end    
    if (times(iter) > stoptime)
        if printOuterItn>0
            fprintf('Exiting because time limit exceeded.\n');
        end
        break;
    end
end
t_stop = toc;

%% Clean up final result
M = normalize(M,'sort',1);

obj = tt_loglikelihood(X,M);
if printOuterItn>0
    normX = norm(X);   
    normresidual = sqrt( normX^2 + norm(M)^2 - 2 * innerprod(X,M) );
    fit = 1 - (normresidual / normX); %fraction explained by model
    fprintf('===========================================\n');
    fprintf(' Final log-likelihood = %e \n', obj);
    fprintf(' Final least squares fit = %e \n', fit);
    fprintf(' Final KKT violation = %7.7e\n', kktViolations(iter));
    fprintf(' Total inner iterations = %d\n', sum(nInnerIters));
    fprintf(' Total execution time = %.2f secs\n', t_stop);
end

output = struct;
output.params = params.Results;
output.kktViolations = kktViolations(1:iter);
output.nInnerIters = nInnerIters(1:iter);
output.nViolations = nViolations(1:iter);
output.nTotalIters = sum(nInnerIters);
output.times = times(1:iter);
output.ttlTime = t_stop;
output.obj = obj;


end

function Pi = calculatePi(X, M, R, n, N)

if (isa(X,'sptensor'))
    Pi = ones(nnz(X), R);
    for nn = [1:n-1,n+1:N]
        Pi = M{nn}(X.subs(:,nn),:) .* Pi;
    end
else
    U = M.U;
    Pi = khatrirao(U{[1:n-1,n+1:N]},'r');
end

end

function Phi = calculatePhi(X, M, R, n, Pi, epsilon)

if (isa(X,'sptensor'))
    Phi = -ones(size(X,n),R);
    xsubs = X.subs(:,n);
    v = sum(M.U{n}(xsubs,:).*Pi,2);
    wvals = X.vals ./ max(v, epsilon);
    for r = 1:R
        Yr = accumarray(xsubs, wvals .* Pi(:,r), [size(X,n) 1]);
        Phi(:,r) = Yr;
    end    
else
    Xn = double(tenmat(X,n));
    V = M.U{n}*Pi';
    W = Xn ./ max(V, epsilon);
    Y = W * Pi;
    Phi = Y;
end

end

%----------------------------------------------------------------------

function y = vectorizeForMu(x)
y = x(:);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Shared Internal Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Pi = tt_calcpi_prowsubprob(X, isSparse, M, R, n, N, sparse_indices)
% TT_CALCPI_PROWSUBPROB Compute Pi for a row subproblem.
%
%   X              - data tensor
%   isSparse       - true if X is sparse, false if dense
%   M              - current factor matrices
%   R              - number of columns in each factor matrix
%   n              - mode
%   N              - number of modes (equals the number of factor matrices)
%   sparse_indices - indices of row subproblem nonzero elements
%
%   Returns Pi matrix.
%
%   Intended for use by CP_PDN and CP_PQN.
%   Based on calculatePi() in CP_APR, which computes for an entire mode
%   instead of a single row subproblem.
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt


    if (isSparse)
        % X is a sparse tensor.  Compute Pi for the row subproblem specified
        % by sparse_indices.
        num_row_nnz = length(sparse_indices);

        Pi = ones(num_row_nnz, R);
        for nn = [1:n-1,n+1:N]
            Pi = M{nn}(X.subs(sparse_indices,nn),:) .* Pi;
        end
    else
        % X is a dense tensor.  Compute Pi for all rows in the mode.
        U = M.U;
        Pi = khatrirao(U{[1:n-1,n+1:N]},'r');
    end

end

%----------------------------------------------------------------------

function [m_new, f_old, f_1, f_new, num_evals] ...
    = tt_linesearch_prowsubprob(d, grad, m_old, step_len, step_red, ...
                                max_steps, suff_decr, isSparse, x_row, Pi, ...
                                phi_row, disp_warn)
% TT_LINESEARCH_PROWSUBPROB Perform a line search on a row subproblem.
%
%   d         - search direction
%   grad      - gradient vector at m_old
%   m_old     - current variable values
%   step_len  - initial step length, which is the maximum possible step length
%   step_red  - step reduction factor (suggest 1/2)
%   max_steps - maximum number of steps to try (suggest 10)
%   suff_decr - sufficient decrease for convergence (suggest 1.0e-4)
%   isSparse  - sparsity flag for computing the objective
%   x_row     - row subproblem data, for computing the objective
%   Pi        - Pi matrix, for computing the objective
%   phi_row   - 1-grad, more accurate if failing over to multiplicative update
%   disp_warn - true means warning messages are displayed
%
%   Returns
%     m_new     - new (improved) variable values
%     num_evals - number of times objective was evaluated
%     f_old     - objective value at m_old
%     f_1       - objective value at m_old + step_len * d
%     f_new     - objective value at m_new

    minDescentTol = 1.0e-7;
    smallStepTol = 1.0e-7;

    stepSize = step_len;

    % Evaluate the current objective value.
    f_old = -1 * tt_loglikelihood_row(isSparse, x_row, m_old, Pi);
    num_evals = 1;
    count = 1;

    while (count <= max_steps)
        % Compute a new step and project it onto the positive orthant.
        m_new = m_old + (stepSize .* d);
        m_new = m_new .* (m_new > 0);

        % Check that it is a descent direction.
        gDotd = sum(grad .* (m_new - m_old));
        if (gDotd > 0) || (sum(m_new) < minDescentTol)
            % Don't evaluate the objective if not a descent direction
            % or if all of the elements of m_new are close to zero.
            f_new = Inf;
            if (count == 1)
               f_1 = f_new;
            end

            stepSize = stepSize * step_red;
            count = count + 1;
        else
            % Evaluate objective function at new iterate.
            f_new = -1 * tt_loglikelihood_row(isSparse, x_row, m_new, Pi);
            num_evals = num_evals + 1;
            if (count == 1)
               f_1 = f_new;
            end

            % Check for sufficient decrease.
            if (f_new <= f_old + suff_decr * gDotd)
                break;
            else
                stepSize = stepSize * step_red;
                count = count + 1;
            end
        end
    end

    % Check if the line search failed.
    if (isinf(f_1) == 1)
        % Unit step failed; return a value that yields ared = 0.
        f_1 = f_old;
    end
    if (   ((count >= max_steps) && (f_new > f_old)) ...
        || (sum(m_new) < smallStepTol) )

        % Fall back on a multiplicative update step (scaled steepest descent).
        % Experiments indicate it works better than a unit step in the direction
        % of steepest descent, which would be the following:
        % m_new = m_old - (step_len * grad);     % steepest descent
        % A simple update formula follows, but suffers from round-off error
        % when phi_row is tiny:
        % m_new = m_old - (m_old .* grad);
        % Use this for best accuracy:
        m_new = m_old .* phi_row;                % multiplicative update

        % Project to the constraints and reevaluate the subproblem objective.
        m_new = m_new .* (m_new > 0);
        f_new = -1 * tt_loglikelihood_row(isSparse, x_row, m_new, Pi);
        num_evals = num_evals + 1;

        % Let the caller know the search direction made no progress.
        f_1 = f_old;

        if (disp_warn)
            fprintf('WARNING: line search failed, using multiplicative update step\n');
        end
    end

end

%----------------------------------------------------------------------

function f = tt_loglikelihood_row(isSparse, x, m, Pi)
%TT_LOGLIKELIHOOD_ROW Compute log-likelihood of one row subproblem.
%
%    The row subproblem for a given mode includes one row of matricized tensor
%    data (x) and one row of the model (m) in the same matricized mode.
%    Then
%       (dense case)
%          m:  R-length vector 
%          x:  J-length vector
%          Pi: R x J matrix
%       (sparse case)
%          m:  R-length vector
%          x:  p-length vector, where p = nnz in row of matricized data tensor
%          Pi: R x p matrix
%       F = - (sum_r m_r - sum_j x_j * log (m * Pi_j)
%           where Pi_j denotes the j^th column of Pi
%           NOTE: Rows of Pi' must sum to one
%
%   isSparse - true if x is sparse, false if dense
%   x        - vector of data values
%   m        - vector of model values
%   Pi       - matrix
%
%   Returns the log-likelihood probability f.
%
%   Intended for use by CP_PDN and CP_PQN.
%   Similar to tt_loglikelihood() in CP_APR, which computes log likelihood
%   for the entire tensor instead of a single row subproblem.
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt


    term1 = -sum(m);

    if (isSparse)
        term2 = sum(x' .* log(m * Pi'));
    else
        b_pi = m * Pi';
        term2 = 0;
        for i = 1:length(x)
            if (x(i) == 0)
                % Define zero times log(anything) to be zero.
            else
                term2 = term2 + x(i) .* log(b_pi(i));
            end
        end
    end

    f = term1 + term2;

end

%----------------------------------------------------------------------

function f = tt_loglikelihood(X,M)
%TT_LOGLIKELIHOOD Compute log-likelihood of data X with model M.
%
%   F = TT_LOGLIKELIHOOD(X,M) computes the log-likelihood of model M given
%   data X, where M is a ktensor and X is a tensor or sptensor.
%   Specifically, F = - (sum_i m_i - x_i * log_i) where i is a multiindex
%   across all tensor dimensions.
%
%   See also cp_apr, tensor, sptensor, ktensor.
%
%MATLAB Tensor Toolbox.
%Copyright 2015, Sandia Corporation.

% This is the MATLAB Tensor Toolbox by T. Kolda, B. Bader, and others.
% http://www.sandia.gov/~tgkolda/TensorToolbox.
% Copyright (2015) Sandia Corporation. Under the terms of Contract
% DE-AC04-94AL85000, there is a non-exclusive license for use of this
% work by or on behalf of the U.S. Government. Export of this data may
% require a license from the United States Government.
% The full license terms can be found in the file LICENSE.txt

N = ndims(X);

if ~isa(M, 'ktensor')
    error('M must be a ktensor');
end

M = normalize(M,1,1);

if isa(X, 'sptensor')
    xsubs = X.subs;
    A = M.U{1}(xsubs(:,1),:);
    for n = 2:N
       A = A .* M.U{n}(xsubs(:,n),:);
    end
    f = sum(X.vals .* log(sum(A,2))) - sum(sum(M.U{1}));
else
%{
% Old code is probably faster, but returns NaN if X and M are both zero
% for some element.
    f = sum(sum(double(tenmat(X,1)) .* log(double(tenmat(M,1))))) - sum(sum(M.U{1}));
%}
    % The check for x==0 is also in tt_loglikelihood_row.
    dX = double(tenmat(X,1));
    dM = double(tenmat(M,1));
    f = 0;
    for i = 1:size(dX,1)
      for j = 1:size(dX,2)
        if (dX(i,j) == 0.0)
          % Define zero times log(anything) to be zero.
        else
          f = f + dX(i,j) * log(dM(i,j));
        end
      end
    end
    f = f - sum(sum(M.U{1}));

end

end
