SPP
===

Sparsity Preserving Projection, a feature extraction algorithm in Pattern Recognition area

+++

Author : Denglong Pan
         pandenglong@gmail.com

+++

What is SPP

Refer to https://github.com/lamplampan/SPP/wiki#what-is-spp

# What is SPP

SPP, Sparsity Preserving Projection, is an unsupervised dimensionality reduction algorithm. It uses the minimum L1 norm to keep the data in sparse reconstruction. 

SPP projections don't affect by the data rotation, scale or offset. SPP can classify the data instinct even though there is no given classified info.

### Sparse refactoring weight matrix

Training sample matrix

<img src="http://latex.codecogs.com/gif.latex?X&space;=&space;[x_{1},&space;x_{2},...,x_{n}]&space;\in&space;R^{m&space;\times&space;n}" title="X = [x_{1}, x_{2},...,x_{n}] \in R^{m \times n}" />

Use the weight vector <img src="http://latex.codecogs.com/gif.latex?s_{i}" title="s_{i}" /> in sparse reconstruction as the coefficient of <img src="http://latex.codecogs.com/gif.latex?x_{i}" title="x_{i}" />, to solve the minimum L1 norm problem. Define the equation set [1] below:

<img src="http://latex.codecogs.com/gif.latex?\underset{s_{i}}{min}||s_{i}||_{1}" title="\underset{s_{i}}{min}||s_{i}||_{l}" />

<img src="http://latex.codecogs.com/gif.latex?x_{i}&space;=&space;Xs_{i}" title="x_{i} = Xs_{i}" />

<img src="http://latex.codecogs.com/gif.latex?l&space;=&space;l^{T}s_{i}" title="l = l^{T}s_{i}" />

Define a sparse refactoring weight matrix below, in which <img src="http://latex.codecogs.com/gif.latex?\tilde{s}_{i}" title="\tilde{s}_{i}" /> is the optimal solution for equation set [1] : 

<img src="http://latex.codecogs.com/gif.latex?S&space;=&space;[&space;\tilde{s}_{1},&space;\tilde{s}_{2},...,&space;\tilde{s}_{n}&space;]^{T}" title="S = [ \tilde{s}_{1}, \tilde{s}_{2},..., \tilde{s}_{n} ]^{T}" />

The weight vector <img src="http://latex.codecogs.com/gif.latex?s_{i}^{0}&space;=&space;[0,...,\alpha&space;_{i,j-1},&space;0&space;,\alpha&space;_{i,j&plus;1}&plus;...&plus;0&space;]^{T}" title="s_{i}^{0} = [0,...,\alpha _{i,i-1}, 0 ,\alpha _{i,i+1}+...+0 ]^{T}" /> is sparse. Because it contains a lot of classes in the face recognition test samples.

The test samples should be as following:

<img src="http://latex.codecogs.com/gif.latex?x_{i}^{j}&space;=&space;0\cdot&space;x_{1}^{1}&space;&plus;&space;...&space;&plus;&space;\alpha&space;_{i,i-1}&space;\cdot&space;x_{i-1}^{j}&space;&plus;&space;\alpha&space;_{i,i&plus;1}&space;\cdot&space;x_{i&plus;1}^{j}&space;&plus;&space;...&space;&plus;&space;0\cdot&space;x_{n}^{c}" title="x_{i}^{j} = 0\cdot x_{1}^{1} + ... + \alpha _{i,i-1} \cdot x_{i-1}^{j} + \alpha _{i,i+1} \cdot x_{i+1}^{j} + ... + 0\cdot x_{n}^{c}" />

We can change the equation set [1] to be following equation set [2] taken the residual into consideration, in which the <img src="http://latex.codecogs.com/gif.latex?\varepsilon" title="\varepsilon" /> is the residual: 

<img src="http://latex.codecogs.com/gif.latex?\underset{s_{i},t}{min}||s_{i}||_{l}" title="\underset{s_{i},t}{min}||s_{i}||_{l}" />

<img src="http://latex.codecogs.com/gif.latex?||x_{i}&space;-&space;Xs_{i}||<\varepsilon" title="||x_{i} - Xs_{i}||<\varepsilon" />

<img src="http://latex.codecogs.com/gif.latex?l&space;=&space;l^{T}&space;s_{i}" title="l = l^{T} s_{i}" />

### Eigenvector extraction

We can define the following objective function [3] in order to find the projection of  preserve optimal weight vector <img src="http://latex.codecogs.com/gif.latex?\tilde{s}_{i}" title="\tilde{s}_{i}" /> 

<img src="http://latex.codecogs.com/gif.latex?\underset{w}{min}\sum_{i=1}^{n}||w^{T}x_{i}&space;-&space;w^{T}X\tilde{s}_{i}||^{2}" title="\underset{w}{min}\sum_{i=1}^{n}||w^{T}x_{i} - w^{T}X\tilde{s}_{i}||^{2}" />

Pass the function above into below one through algebraic transformation, in which the <img src="http://latex.codecogs.com/gif.latex?S_{\beta&space;}&space;=&space;S&space;&plus;&space;S^{T}&space;-S^{T}S" title="S_{\beta } = S + S^{T} -S^{T}S" />

<img src="http://latex.codecogs.com/gif.latex?\underset{w}{max}\frac{w^{T}XS_{\beta&space;}X^{T}w}{w^{T}XX^{T}w}" title="\underset{w}{max}\frac{w^{T}XS_{\beta }X^{T}w}{w^{T}XX^{T}w}" />

The eigenvector would be the maximum d eigenvalues in the following resolution. 

<img src="http://latex.codecogs.com/gif.latex?XS_{\beta&space;}X^{T}w&space;=&space;\lambda&space;XX^{T}w" title="XS_{\beta }X^{T}w = \lambda XX^{T}w" />

### SPP algorithm

**Step 1** Use the equation set [1] or equation set [2] to calculate the weight matrix S. It can be calculated by the standard linear programming tools such as L1-magic etc.

**Step 2**  Calculate the projection vector by objective function [3]. Then we can get the d maximum eigenvalues in the subspace and also get the corresponding eigenvectors.

### Test result on ORL face lib

Use PCA + SPP +SRC for the testing.

**Why use PCA here**

We use PCA here to reduce the dimensions. There are 92*112 = 10304 dimensions in each face sample. There are 40 kinds of faces in ORL lib. Each kinds of face contains 10 samples. If we use 5 in each kind of face as training samples, then the constructed matrix is 10304*40*5 . It will confront of two problems with so many dimensions:

1 MATLAB will report "OUT OF MEMORY" with so many dimensions matrix.

2 The row number is bigger than column, so that it should be a overdetermined equation. It cannot be solved by L1_MAGIC algorithm.

**Test results** 

Use 5 samples in 40 kinds of face to train. Use the left samples to be tested. Set the residual to be 0.0001 . Set the extracted projected vectors to be 80.

The recognized rate is 93% when the PCA=80 . 



+++

How to run the algorithm?

Refer to https://github.com/lamplampan/SPP/wiki#how-to-run

# How to run

**Step 1** : Config your ORL face lib in file orl_src.m . Default path is E:\ORL_face\orlnumtotal\  .

**Step 2** : Run orl_src.m
