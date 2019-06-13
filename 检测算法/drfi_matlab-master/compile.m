cd ./mex
mex mexFeatureDistance.cpp
mex mexLBP.cpp
cd ..

cd ./segmentation/segment
mex mexSegment.cpp
cd ../..

cd ./randomforest-matlab/RF_Reg_C
mex src/cokus.cpp src/reg_RF.cpp src/mex_regressionRF_train.cpp   -DMATLAB -output mexRF_train
mex src/cokus.cpp src/reg_RF.cpp src/mex_regressionRF_predict.cpp   -DMATLAB  -output mexRF_predict
cd ../..

cd ./multi-segmentation
mex mexMergeAdjRegs_Felzenszwalb.cpp 
%mex mexMergeAdjacentRegions.cpp
%mex mexMergeAdjacentRegions2.cpp
cd ..

cd ./randomforest-matlab\RF_Reg_C\compress
mex mexCharArray2DoubleArray.cpp
mex mexDoubleArray2CharArray.cpp