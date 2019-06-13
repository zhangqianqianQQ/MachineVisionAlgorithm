% Tensor Toolbox (Sandia National Labs)
% Version 2.6 06-FEB-2015
% Tensor Toolbox for dense, sparse, and decomposed n-way arrays.
% 
% Tensor Toolbox Classes:
%   Tensor     - Dense tensors.
%   Sptensor   - Sparse tensors.
%   Ktensor    - Kruskal decomposed tensors.
%   TTensor    - Tucker decomposed tensors.
%   Tenmat     - Tensor as matrix.
%   Sptenmat   - Sparse tensor as matrix.
% 
% Tensor Toolbox Functions:
%   cp_als         - Compute a CP decomposition of any type of tensor.
%   cp_apr         - Compute nonnegative CP with alternating Poisson regression.
%   cp_nmu         - Compute nonnegative CP with multiplicative updates.
%   cp_opt         - Fits a CP model to a tensor via optimization.
%   cp_wopt        - Fits a weighted CP model to a tensor via optimization.
%   create_guess   - Creates initial guess for CP or Tucker fitting.
%   create_problem - Create test problems for tensor factorizations.
%   eig_geap       - Shifted power method for generalized tensor eigenproblem.
%   eig_sshopm     - Shifted power method for finding real eigenpair of real tensor.
%   eig_sshopmc    - Shifted power method for real/complex eigenpair of tensor.
%   export_data    - Export tensor-related data to a file.
%   import_data    - Import tensor-related data to a file.
%   khatrirao      - Khatri-Rao product of matrices.
%   matrandcong    - Create a random matrix with a fixed congruence.
%   matrandnorm    - Normalizes columns of X so that each is unit 2-norm.
%   matrandorth    - Generates random n x n orthogonal real matrix.
%   sptendiag      - Creates a sparse tensor with v on the diagonal.
%   sptenrand      - Sparse uniformly distributed random tensor.
%   tendiag        - Creates a tensor with v on the diagonal.
%   teneye         - Create identity tensor of specified size.
%   tenones        - Ones tensor.
%   tenrand        - Uniformly distributed pseudo-random tensor.
%   tenzeros       - Create zeros tensor.
%   tt_ind2sub     - Multiple subscripts from linear indices.
%   tt_sub2ind     - Converts multidimensional subscripts to linear indices.
%   tucker_als     - Higher-order orthogonal iteration.
%   tucker_sym     - Symmetric Tucker approximation.
