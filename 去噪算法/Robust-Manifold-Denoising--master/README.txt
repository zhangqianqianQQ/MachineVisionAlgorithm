Shay Deutsch (shaydeu@math.ucla.edu)
(c) Shay Deutsch, 2018

This packaged is an implementation of our paper "Robust Denoising of Piece-Wise Smooth Manifolds", ICASSP 2018

The algorithm creates an affinity graph and perform denoising on a set of N input points in R^n.

Given an input set of points in any arbitrary dimension, an affinity graph is first created based on Tensor Voting, Local PCA or Euclidean distances, or the Tensor Voting Graph [3] .  Then it performs denoising using a modified version of the recently proposed  MFD algorithm[1]. The MFD algorithm uses the Spectral Graph Wavelet (SGW) transform [2] in order to perform denoising directly in the spectral graph wavelet domain.  \

Main function -  Main_Demo provides an example of running our algorithm
The code uses the Spectral Graph Wavelets transform packedge download from 
https://wiki.epfl.ch/sgwt


affinity.createAffMatrix  - function which creats an affinity matrix based on local PCA, Tensor Voting Graph, or K nearest neighbors graph based on Euclidean distances. \
feats                       - input set of points, possibly noisy \
params,params.affinity_type - parameters to create the graph, including number of k nearest neighbor and type of graph (Euclidean based, local tangent distance based) \
loadParams - loading parameters for creating the affinity matrix based on Tensor Voting, local PCA, or Euclidean distances
loadData  -loading the data
W  -  NxN Affinity matrix obtained from the selected  affinity graph based method
L  -  Laplacian 
feats_denoised          -  nxN matrix correspond to the set of points denoised 

Installation of the toolbox is simple, simply unpack the directory. 
Then, you may try running the demo
License : 

This toolbox is a Matlab library released under the GPL.

The toolbox is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.


This toolbox is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this toolbox.  If not, see <http://www.gnu.org/licenses/>.

Refrences:
[1] Shay Deutsch, Antonio Ortega, and Gerard Medioni. Robust Denoising of Piece-Wise Smooth Manifold. IEEE International Conference on Acoustics, Speech and Signal Processing ICASSP, 2018. \
[2] David K. Hammond, Pierre Vandergheynst, and Remi Gribonval. Wavelets on graphs via spectral graph theory. Applied and Computational Harmonic Analysis, 30(2):129\'96150, March 2011. \
[3] Shay Deutsch and Gerard Medioni. Unsupervised learning using the tensor voting graph. SSVM 2015: Fifth International Conference on Scale Space and Variational Methods in Computer Vision, 2015.
[4] Specteal Graph Wavelets toolbox: https://wiki.epfl.ch/sgwt
