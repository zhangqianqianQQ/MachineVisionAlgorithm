# Graph-Multi-NMF-Feature-Clustering

## Introduction

Codes for [__Feature Extraction via Multi-view Non-negative Matrix Factorization with Local Graph Regularization__](https://github.com/DUT-DIPLab/Graph-Multi-NMF-Feature-Clustering/files/389/ICIP_2015_wang.pdf). 

Motivated by manifold learning and multi-view Non-negative Matrix Factorization (NMF), we introduce a novel feature extraction method via multi-view NMF with local graph regularization, where the inner-view relatedness between data is taken into consideration. We propose the matrix factorization objective function by constructing a nearest neighbor graph to integrate local geometrical information of each view and apply two iterative updating rules to effectively solve the optimization problem.

Please cite the following information:

```latex
@inproceedings{wang2015multi,
  title={Feature Extraction via Multi-view Non-negative Matrix Factorization with Local Graph Regularization},
  author={Wang, Zhenfan and Kong, Xiangwei and Fu, Haiyan and Li, Ming and Zhang, Yujia},
  booktitle={Image Processing (ICIP), 2015 IEEE International Conference on},
  year={2015},
  organization={IEEE}
}
```

## Demo

There is a demo in `GMultiNMF/demo_digit.m` working for hand-written digits recognition. You may see releases to access the full paper and download the demo dataset.

## Results

The accuracy (AC) and normalized mutual information (NMI) of different algorithms on three datasets:

![1](https://cloud.githubusercontent.com/assets/853842/8086601/c6d273f2-0fc8-11e5-8ceb-85c84239ec06.png)

![2](https://cloud.githubusercontent.com/assets/853842/8086602/c70111a8-0fc8-11e5-9f6e-63f4d02a67b7.png)

From the tables, we can see that our proposed algorithm performs better in each dataset in terms of AC and NMI. Although other methods consider multiple feature integration, Co-reguSC and SC-ML use latent data relationship, the results demonstrate that our proposed Multi-view NMF with local graph regularization feature extraction framework can learn a better feature representation.
